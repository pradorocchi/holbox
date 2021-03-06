import AppKit

final class Text: NSTextView {
    var tab = false
    var intro = false
    var clear = false
    var caret = CGFloat(2)
    let edit: Edit
    private let resize: Resize
    override var acceptsFirstResponder: Bool { edit.active }
    override var mouseDownCanMoveWindow: Bool { !edit.active }
    override var canBecomeKeyView: Bool { edit.active }
    override var isSelectable: Bool { get { edit.active } set { } }
    override func accessibilityValue() -> String? { string }
    
    required init?(coder: NSCoder) { nil }
    init(_ resize: Resize, _ edit: Edit, storage: NSTextStorage) {
        self.resize = resize
        self.edit = edit
        super.init(frame: .zero, textContainer: Container(storage))
        setAccessibilityElement(true)
        setAccessibilityRole(.textField)
        translatesAutoresizingMaskIntoConstraints = false
        allowsUndo = true
        isRichText = false
        drawsBackground = false
        isContinuousSpellCheckingEnabled = app.session.spell
        isAutomaticTextCompletionEnabled = app.session.spell
        insertionPointColor = .haze()
        selectedTextAttributes = [.backgroundColor: NSColor.haze(), .foregroundColor: NSColor.black]
        resize.configure(self)
    }
    
    override final func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
        var rect = rect
        rect.size.width = caret
        super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
    }
    
    override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout: Bool) {
        var rect = rect
        rect.size.width += caret
        super.setNeedsDisplay(rect, avoidAdditionalLayout: avoidAdditionalLayout)
    }
    
    override func didChangeText() {
        super.didChangeText()
        resize.update(self)
    }
    
    override func becomeFirstResponder() -> Bool {
        textContainer!.lineBreakMode = .byTruncatingMiddle
        delegate?.textDidBeginEditing?(.init(name: .init("")))
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setSelectedRange(.init())
        textContainer!.lineBreakMode = .byTruncatingTail
        edit.resign()
        return super.resignFirstResponder()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 3, 5, 45:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                window!.keyDown(with: with)
            } else {
                super.keyDown(with: with)
            }
        case 12:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                app.terminate(nil)
            } else {
                super.keyDown(with: with)
            }
        case 53:
            if clear {
                string = ""
                delegate?.textDidChange?(.init(name: .init("")))
            }
            window!.makeFirstResponder(superview!)
        case 48:
            if tab {
                super.keyDown(with: with)
            } else {
                window!.keyDown(with: with)
                window!.makeFirstResponder(superview!)
            }
        case 36:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                window!.makeFirstResponder(superview!)
                superview!.keyDown(with: with)
            } else if intro {
                super.keyDown(with: with)
            } else {
                window!.keyDown(with: with)
                window!.makeFirstResponder(superview!.superview!)
            }
        default: super.keyDown(with: with)
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if edit.active {
            isEditable = true
            super.mouseDown(with: with)
        } else if with.clickCount == 2 {
            click()
        } else {
            superview!.mouseDown(with: with)
        }
    }
    
    override func rightMouseUp(with: NSEvent) {
        if !edit.active && bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            edit.right()
            if edit.active {
                setSelectedRange(.init(location: 0, length: string.utf16.count))
                window!.makeFirstResponder(self)
            }
        } else {
            super.rightMouseUp(with: with)
        }
    }
    
    override func layout() {
        super.layout()
        resize.layout(self)
    }
    
    func click() {
        edit.click()
        if edit.active {
            window!.makeFirstResponder(self)
        }
    }
}
