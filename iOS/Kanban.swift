import UIKit

final class Kanban: Base.View {
    private weak var name: Label?
    private weak var scroll: Scroll!
    private weak var border: Border!
    private weak var _card: Button!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border()
        scroll.add(border)
        self.border = border
        
        let _card = Button("card", target: self, action: #selector(card))
        self._card = _card
        
        let _more = Button("more", target: self, action: #selector(more))
        
        [_card, _more].forEach {
            scroll.add($0)
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: _more.rightAnchor, constant: 20).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: border.bottomAnchor, constant: 20).isActive = true
        scroll.width.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        
        _more.leftAnchor.constraint(equalTo: _card.rightAnchor).isActive = true
        _more.centerYAnchor.constraint(equalTo: _card.centerYAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Card || $0 is Column }.forEach { $0.removeFromSuperview() }
        rename()
        
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.lists(app.project)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            var top: Card?
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let card = Card(self, index: $0, column: list)
                scroll.add(card)
                
                if top == nil {
                    card.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 10).isActive = true
                } else {
                    card.topAnchor.constraint(equalTo: top!.bottomAnchor).isActive = true
                }
                
                scroll.bottom.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 20).isActive = true
                column.rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor).isActive = true
                card.leftAnchor.constraint(equalTo: column.leftAnchor).isActive = true
                top = card
            }
            
            if left == nil {
                column.leftAnchor.constraint(equalTo: scroll.left, constant: 5).isActive = true
            } else {
                column.leftAnchor.constraint(equalTo: left!).isActive = true
            }
            
            border.topAnchor.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: -15).isActive = true
            
            column.centerYAnchor.constraint(equalTo: name!.bottomAnchor, constant: 40).isActive = true
            scroll.bottom.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 40).isActive = true
            left = column.rightAnchor
        }
        
        if left != nil {
            scroll.right.constraint(greaterThanOrEqualTo: left!, constant: 20).isActive = true
        }
    }
    
    private func rename() {
        self.name?.removeFromSuperview()
        let string = app.session.name(app.project)
        let name = Label(string.mark {
            switch $0 {
            case .plain: return (.init(string[$1]), 26, .bold, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .emoji: return (.init(string[$1]), 40, .regular, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .bold: return (.init(string[$1]), 30, .bold, UIColor(named: "haze")!.withAlphaComponent(0.7))
            }
        })
        name.accessibilityLabel = .key("Project")
        name.accessibilityValue = string
        name.numberOfLines = 1
        addSubview(name)
        self.name = name
        
        name.centerYAnchor.constraint(equalTo: scroll.top, constant: 50).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.left, constant: 25).isActive = true
        name.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        _card.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        _card.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
    }
    
    @objc private func card() {
        app.session.add(app.project, list: 0)
        refresh()
        scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column == 0 }!.edit()
    }
}
