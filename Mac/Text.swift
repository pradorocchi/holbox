import AppKit

final class Text: NSTextView {
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(4)
        
        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<NSRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<NSRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: NSRect, usedRect: NSRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    var edit = false
    override var acceptsFirstResponder: Bool { edit }
    override var mouseDownCanMoveWindow: Bool { !edit }
    override var canBecomeKeyView: Bool { edit }
    override var isEditable: Bool { get { edit } set { } }
    override var isSelectable: Bool { get { edit } set { } }
    private weak var width: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        let storage = NSTextStorage()
        super.init(frame: .zero, textContainer: {
            $1.delegate = $1
            storage.addLayoutManager($1)
            $1.addTextContainer($0)
            $0.lineBreakMode = .byTruncatingTail
            return $0
        } (NSTextContainer(), Layout()))
        textContainerInset.height = 10
        textContainerInset.width = 10
        setAccessibilityElement(true)
        setAccessibilityRole(.textField)
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .white
        allowsUndo = true
        isRichText = false
        drawsBackground = false
        isContinuousSpellCheckingEnabled = true
        insertionPointColor = .haze
        isAutomaticTextCompletionEnabled = true
        alphaValue = 0.3
        
        width = widthAnchor.constraint(equalToConstant: 0)
        width.isActive = true
    }
    
    override final func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
        var rect = rect
        rect.size.width = 3
        super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
    }
    
    override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout: Bool) {
        var rect = rect
        rect.size.width += 3
        super.setNeedsDisplay(rect, avoidAdditionalLayout: avoidAdditionalLayout)
    }
    
    override func didChangeText() {
        super.didChangeText()
        width.constant = layoutManager!.usedRect(for: textContainer!).size.width + 20
    }
    
    override func becomeFirstResponder() -> Bool {
        alphaValue = 1
        textContainer!.lineBreakMode = .byTruncatingMiddle
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setSelectedRange(.init())
        alphaValue = 0.3
        textContainer!.lineBreakMode = .byTruncatingTail
        return super.resignFirstResponder()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36, 48, 53: window!.makeFirstResponder(superview!)
        default: super.keyDown(with: with)
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if with.clickCount == 2 && !edit {
            edit = true
            window!.makeFirstResponder(self)
        }
        super.mouseDown(with: with)
    }
}