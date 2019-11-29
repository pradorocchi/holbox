import AppKit

final class Tag: NSView {
    private let name: String
    
    required init?(coder: NSCoder) { nil }
    init(_ name: String, count: Int) {
        self.name = name
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel("\(count) #" + name)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = NSColor(named: "haze")!.cgColor
        base.layer!.cornerRadius = 4
        addSubview(base)
        
        let label = Label("#" + name, 14, .bold, .black)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setAccessibilityElement(false)
        addSubview(label)
        
        let _count = Label("\(count)", 14, .medium, NSColor(named: "haze")!)
        _count.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        _count.setAccessibilityElement(false)
        addSubview(_count)
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 20).isActive = true
        
        base.topAnchor.constraint(equalTo: label.topAnchor, constant: -5).isActive = true
        base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 5).isActive = true
        base.leftAnchor.constraint(equalTo: label.leftAnchor, constant: -10).isActive = true
        base.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
        
        label.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        
        _count.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        _count.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            app.main.bar.find.search("#"+name)
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
}
