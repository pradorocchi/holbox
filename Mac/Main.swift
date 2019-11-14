import AppKit

final class Main: Window.Full {
    private weak var base: Base!
    private weak var bar: Bar!
    private weak var logo: Logo?

    init() {
        super.init(800, 700)
        minSize = .init(width: 100, height: 100)
        setFrameOrigin(.init(x: NSScreen.main!.frame.midX - 400, y: NSScreen.main!.frame.midY - 200))
        
        let logo = Logo()
        logo.start()
        contentView!.addSubview(logo)
        self.logo = logo
        
        logo.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
    }
    
    override func close() { app.terminate(nil) }
    
    override func zoom(_ sender: Any?) {
        contentView!.layer!.cornerRadius = isZoomed ? 20 : 0
        super.zoom(sender)
    }
    
    func loaded() {
        logo!.stop()
        logo!.removeFromSuperview()
        
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
    }
    
    func project(_ project: Int) {
        app.project = project
//        bar?._kanban.selected = false
//        bar?._todo.selected = false
//        bar?._shopping.selected = false
//        bar?._shop.selected = false
        switch app.mode {
        case .todo: base?.show(Todo())
        case .shopping: base?.show(Shopping())
        default: base?.show(Kanban())
        }
        bar.project()
    }
    
    func detail() {
        base.show(Detail())
        bar.detail()
    }
    
    func refresh() {
        base.refresh()
        bar.refresh()
    }
    
    func clear() {
        base.clear()
    }
    /*
    @objc func kanban() {
        app.refresh()
        app.mode = .kanban
        bar?._kanban.selected = true
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func todo() {
        app.refresh()
        app.mode = .todo
        bar?._kanban.selected = false
        bar?._todo.selected = true
        bar?._shopping.selected = false
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func shopping() {
        app.refresh()
        app.mode = .shopping
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = true
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func shop() {
        app.mode = .off
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = true
        base?.show(Shop())
    }*/
    
    @objc func shop() {
        app.runModal(for: Shop())
    }
    
    @objc func more() {
        app.runModal(for: More.Main())
    }
    
    @objc func about() {
        app.runModal(for: About())
    }
    
    @objc func full() { zoom(self) }
}
