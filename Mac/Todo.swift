import AppKit

final class Todo: View, NSTextViewDelegate {
    private(set) weak var tags: Tags!
    private weak var ring: Ring!
    private weak var scroll: Scroll!
    private weak var new: Text!
    private weak var _right: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border.vertical()
        addSubview(border)
        
        let tags = Tags()
        addSubview(tags)
        self.tags = tags
        
        let new = Text(.Fix(), Active())
        new.textContainerInset.width = 10
        new.textContainerInset.height = 10
        new.setAccessibilityLabel(.key("Task"))
        new.font = NSFont(name: "Times New Roman", size: 22)
        (new.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 22, weight: .medium), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 30)!, .white),
                                               .bold: (.systemFont(ofSize: 24, weight: .bold), .white),
                                               .tag: (.systemFont(ofSize: 20, weight: .medium), NSColor(named: "haze")!)]
        new.intro = true
        new.tab = true
        new.delegate = self
        scroll.add(new)
        self.new = new
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Todo.add"))
        scroll.add(_add)
        
        let ring = Ring()
        addSubview(ring)
        self.ring = ring
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: _add.bottomAnchor, constant: 40).isActive = true
        
        border.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        
        tags.rightAnchor.constraint(lessThanOrEqualTo: border.leftAnchor).isActive = true
        tags.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 20).isActive = true
        let tagsLeft = tags.leftAnchor.constraint(equalTo: leftAnchor, constant: 10)
        tagsLeft.priority = .defaultLow
        tagsLeft.isActive = true
        
        ring.rightAnchor.constraint(lessThanOrEqualTo: border.leftAnchor).isActive = true
        ring.topAnchor.constraint(equalTo: topAnchor).isActive = true
        let ringLeft = ring.leftAnchor.constraint(equalTo: leftAnchor, constant: 10)
        ringLeft.priority = .defaultLow
        ringLeft.isActive = true
        
        new.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -60).isActive = true
        new.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
        _right = new.rightAnchor.constraint(equalTo: scroll.left)
        _right.isActive = true
        
        _add.topAnchor.constraint(equalTo: scroll.top).isActive = true
        _add.leftAnchor.constraint(equalTo: new.rightAnchor).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let top = _add.topAnchor.constraint(equalTo: scroll.top)
        top.priority = .defaultLow
        top.isActive = true
        
        refresh()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                add()
            } else {
                window!.makeFirstResponder(new)
                new.setSelectedRange(.init(location: new.string.count, length: 0))
            }
        case 48:
            window!.makeFirstResponder(new)
            new.setSelectedRange(.init(location: 0, length: new.string.count))
        default: super.keyDown(with: with)
        }
    }
    
    func textDidEndEditing(_: Notification) {
        if new.string.isEmpty {
            _right.constant = 0
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                scroll.documentView!.layoutSubtreeIfNeeded()
            }
        }
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
        
        var top: NSLayoutYAxisAnchor?
        [0, 1].forEach { list in
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let task = Task($0, list: list, todo: self)
                scroll.add(task)

                if top == nil {
                    task.topAnchor.constraint(equalTo: new.bottomAnchor).isActive = true
                } else {
                    task.topAnchor.constraint(equalTo: top!).isActive = true
                }
                task.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                task.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
                top = task.bottomAnchor
            }
        }
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 50).isActive = true
        }
    
        ring.current = .init(app.session.cards(app.project, list: 1))
        ring.total = .init(app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))
        ring.refresh()
        tags.refresh()
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Task }.forEach { task in
            let ranges = ranges.filter { $0.0 == task.list && $0.1 == task.index }.map { $0.2 as NSValue }
            if ranges.isEmpty {
                task.text.setSelectedRange(.init())
            } else {
                task.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        let text = scroll.views.compactMap { $0 as? Task }.first { $0.list == list && $0.index == card }!.text!
        text.showFindIndicator(for: range)
        scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
    }
    
    override func add() {
        if new.string.isEmpty {
            _right.constant = 340
            window!.makeFirstResponder(new)
        } else {
            if !new.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                app.session.add(app.project, list: 0, content: new.string)
                app.alert(.key("Task"), message: new.string)
                refresh()
            }
            new.string = ""
            new.needsLayout = true
            _right.constant = 0
        }
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
            scroll.contentView.scroll(to: .zero)
        }
    }
}
