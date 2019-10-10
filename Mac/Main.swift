import holbox
import AppKit

final class Main: Window {
    private(set) var mode = Mode.kanban
    private weak var bar: Bar!
    private weak var base: NSView!

    init() {
        super.init(800, 700, mask: [.miniaturizable, .resizable])
        minSize = .init(width: 400, height: 300)
        setFrameOrigin(.init(x: NSScreen.main!.frame.midX - 400, y: NSScreen.main!.frame.midY - 250))
        
        let bar = Bar()
        contentView!.addSubview(bar, positioned: .below, relativeTo: _close)
        self.bar = bar
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    override func close() { app.terminate(nil) }
    
    override func becomeKey() {
        super.becomeKey()
        bar.alphaValue = 1
    }
    
    override func resignKey() {
        super.resignKey()
        bar.alphaValue = 0.3
    }
    
    func kanban() {
        mode = .kanban
    }
    
    func todo() {
        mode = .todo
    }
    
    func shopping() {
        mode = .shopping
    }
    
    private func show(_ view: NSView) {
        base.subviews.forEach { $0.removeFromSuperview() }
        view.alphaValue = 0
        base.addSubview(view)
        
        view.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 1
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
        }) {
            self.makeFirstResponder(view)
        }
    }
}
