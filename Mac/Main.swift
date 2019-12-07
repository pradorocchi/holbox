import AppKit

final class Main: Window {
    private(set) weak var bar: Bar!
    private weak var base: Base!
    private weak var logo: Logo!
    
    init() {
        super.init(1200, 900, mask: [.miniaturizable, .resizable])
        contentView!.layer!.backgroundColor = .black
        minSize = .init(width: 100, height: 100)
        setFrameOrigin(.init(x: NSScreen.main!.frame.midX - 600, y: NSScreen.main!.frame.midY - 450))
        
        let _close = Tool("close", action: #selector(close))
        _close.setAccessibilityLabel(.key("Main.close"))
        
        let _minimise = Tool("minimise", action: #selector(miniaturize(_:)))
        _minimise.setAccessibilityLabel(.key("Main.minimise"))
        
        let _zoom = Tool("zoom", action: #selector(zoom(_:)))
        _zoom.setAccessibilityLabel(.key("Main.zoom"))
        
        [_close, _minimise, _zoom].forEach {
            contentView!.addSubview($0)
            $0.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        }
        
        let logo = Logo()
        logo.start()
        contentView!.addSubview(logo)
        self.logo = logo
        
        logo.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        _close.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 19).isActive = true
        _minimise.leftAnchor.constraint(equalTo: _close.rightAnchor, constant: 8).isActive = true
        _zoom.leftAnchor.constraint(equalTo: _minimise.rightAnchor, constant: 8).isActive = true
    }
    
    override func close() { app.terminate(nil) }
    
    override func zoom(_ sender: Any?) {
        contentView!.layer!.cornerRadius = isZoomed ? 10 : 0
        super.zoom(sender)
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 3:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                bar.find.show()
            } else {
                super.keyDown(with: with)
            }
        case 5:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                bar.find.next()
            } else {
                super.keyDown(with: with)
            }
        case 45:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
                let view = base.subviews.first as? View {
                makeFirstResponder(view)
                view.add()
            } else {
                super.keyDown(with: with)
            }
        default: super.keyDown(with: with)
        }
    }
    
    func loaded() {
        logo.stop()
        logo.removeFromSuperview()
        
        let bar = Bar()
        contentView!.addSubview(bar, positioned: .below, relativeTo: nil)
        self.bar = bar
        
        let base = Base()
        contentView!.addSubview(base)
        self.base = base
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        let height = bar.heightAnchor.constraint(equalTo: contentView!.heightAnchor)
        height.priority = .defaultLow
        height.isActive = true
        
        base.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        refresh()
    }
    
    func refresh() {
        bar.refresh()
        base.refresh()
    }
    
    @objc func about() {
        app.runModal(for: About())
    }
    
    @objc func full() { zoom(self) }
}
