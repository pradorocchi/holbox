import UIKit

final class Detail: Base.View {
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let _add = Button("plus", target: self, action: #selector(add))
        addSubview(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 80).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 80).isActive = true
        _add.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        _add.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let image = Image("detail.\(app.mode.rawValue)")
        image.contentMode = .scaleAspectFit
        scroll.add(image)
        
        let title = Label(.key("Detail.title.\(app.mode.rawValue)"), 30, .bold, UIColor(named: "haze")!.withAlphaComponent(0.5))
        scroll.add(title)
        
        let border = Border()
        scroll.add(border)
        
        if app.session.projects(app.mode).isEmpty {
            let empty = Label(.key("Detail.empty.\(app.mode.rawValue)"), 14, .light, .init(white: 1, alpha: 0.5))
            scroll.add(empty)
            
            empty.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
            empty.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 33).isActive = true
            
            scroll.bottom.constraint(greaterThanOrEqualTo: empty.bottomAnchor, constant: 40).isActive = true
        } else {
            var top: NSLayoutYAxisAnchor?
            app.session.projects(app.mode).forEach {
                let item = Item(app.session.name($0), index: $0, .bold, UIColor(named: "haze")!, self, #selector(project(_:)))
                scroll.add(item)
                
                item.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 13).isActive = true
                item.widthAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.widthAnchor, constant: -26).isActive = true
                
                if top == nil {
                    item.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 10).isActive = true
                } else {
                    let border = Border()
                    scroll.add(border)
                    
                    border.leftAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.leftAnchor, constant: 33).isActive = true
                    border.rightAnchor.constraint(equalTo: scroll.safeAreaLayoutGuide.rightAnchor, constant: -33).isActive = true
                    border.topAnchor.constraint(equalTo: top!, constant: 10).isActive = true
                    
                    item.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 10).isActive = true
                }
                
                top = item.bottomAnchor
            }
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
        
        image.widthAnchor.constraint(equalToConstant: 120).isActive = true
        image.heightAnchor.constraint(equalToConstant: 120).isActive = true
        image.topAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: border.leftAnchor).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 50).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.leftAnchor, constant: 33).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.rightAnchor, constant: -33).isActive = true
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc private func add() {
        app.present(Add(), animated: true)
    }
    
    @objc private func project(_ item: Item) {
        app.main.project(item.index)
    }
}
