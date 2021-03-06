import holbox
import AppKit

final class Add: Modal {
    private weak var name: Label!
    private weak var selected: Button! {
        didSet {
            oldValue?.icon.alphaValue = 0.4
            oldValue?.layer!.borderColor = .clear
            selected.layer!.borderColor = .haze()
            selected.icon.alphaValue = 1
        }
    }
    
    private var mode = Mode.off
    
    init() {
        super.init(420, 500)
        let icon = Image("new")
        contentView!.addSubview(icon)
        
        let title = Label([(.key("Add.title") + "\n", .medium(18), .haze()),
                           (.key("Add.subtitle"), .light(14), .haze(0.8))])
        contentView!.addSubview(title)
        
        let available = Label([(.key("Add.available") + "\n\n", .light(18), .haze(0.6)),
                               ("\(app.session.available)", .medium(32), .haze())], align: .center)
        contentView!.addSubview(available)
        
        let projects = Label([(.key("Add.projects"), .light(14), .haze(0.6)),
                              ("\n\n\(app.session.count)", .medium(18), .haze())], align: .center)
        contentView!.addSubview(projects)
        
        let capacity = Label([(.key("Add.capacity"), .light(14), .haze(0.6)),
                              ("\n\n\(app.session.capacity)", .medium(18), .haze())], align: .center)
        contentView!.addSubview(capacity)
        
        let cancel = Control(.key("Add.cancel"), self, #selector(close), .clear, .haze())
        contentView!.addSubview(cancel)
        
        icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        icon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 120).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 52).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 52).isActive = true

        title.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        
        available.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 40).isActive = true
        available.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        projects.centerYAnchor.constraint(equalTo: available.centerYAnchor).isActive = true
        projects.rightAnchor.constraint(equalTo: available.leftAnchor, constant: -20).isActive = true
        
        capacity.centerYAnchor.constraint(equalTo: available.centerYAnchor).isActive = true
        capacity.leftAnchor.constraint(equalTo: available.rightAnchor, constant: 20).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 160).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
        cancel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        if app.session.available > 0 {
            let _kanban = Button("kanban", target: self, action: #selector(kanban(_:)))
            _kanban.setAccessibilityLabel(.key("Add.kanban"))
            
            let _todo = Button("todo", target: self, action: #selector(todo(_:)))
            _todo.setAccessibilityLabel(.key("Add.todo"))
            
            let _shopping = Button("shopping", target: self, action: #selector(shopping(_:)))
            _shopping.setAccessibilityLabel(.key("Add.shopping"))
            
            let _notes = Button("notes", target: self, action: #selector(notes(_:)))
            _notes.setAccessibilityLabel(.key("Add.notes"))
            
            let name = Label("", .bold(18), .haze())
            contentView!.addSubview(name)
            self.name = name
            
            let _confirm = Control(.key("Add.confirm"), self, #selector(add), .haze(), .black)
            contentView!.addSubview(_confirm)
            
            var left: NSLayoutXAxisAnchor?
            [_kanban, _todo, _shopping, _notes].forEach {
                $0.icon.alphaValue = 0.4
                $0.wantsLayer = true
                $0.layer!.cornerRadius = 4
                $0.layer!.borderWidth = 1
                $0.layer!.borderColor = .clear
                contentView!.addSubview($0)
                
                $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
                $0.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 60).isActive = true
                
                if left == nil {
                    $0.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 100).isActive = true
                } else {
                    $0.leftAnchor.constraint(equalTo: left!, constant: 20).isActive = true
                }
                
                left = $0.rightAnchor
            }
            
            name.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 130).isActive = true
            name.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            
            _confirm.widthAnchor.constraint(equalToConstant: 160).isActive = true
            _confirm.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            _confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -10).isActive = true
            
            kanban(_kanban)
        } else {
            let info = Label(.key("Add.info"), .light(16), .white)
            contentView!.addSubview(info)
            
            let _purchases = Control(.key("Add.purchases"), self, #selector(purchases), .haze(), .black)
            contentView!.addSubview(_purchases)
            
            info.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 30).isActive = true
            info.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 50).isActive = true
            info.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -50).isActive = true
            
            _purchases.widthAnchor.constraint(equalToConstant: 160).isActive = true
            _purchases.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -10).isActive = true
            _purchases.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
    }
    
    @objc private func add() {
        app.project = app.session.add(mode)
        close()
    }
    
    @objc private func kanban(_ button: Button) {
        mode = .kanban
        name.stringValue = .key("Add.kanban")
        selected = button
    }
    
    @objc private func todo(_ button: Button) {
        mode = .todo
        name.stringValue = .key("Add.todo")
        selected = button
    }
    
    @objc private func shopping(_ button: Button) {
        mode = .shopping
        name.stringValue = .key("Add.shopping")
        selected = button
    }
    
    @objc private func notes(_ button: Button) {
        mode = .notes
        name.stringValue = .key("Add.notes")
        selected = button
    }
    
    @objc private func purchases() {
        close()
        app.main.bar.shop()
    }
}
