import AppKit

final class Add: Modal {
    private weak var _confirm: Control!
    private weak var _purchases: Control!
    
    init() {
        super.init(400, 600)
        let icon = Image("new")
        
        let title = Label(.key("Add.title.\(app.mode.rawValue)"), size: 20, weight: .bold)
        title.textColor = .white
        
        let subtitle = Label(.key("Add.subtitle.\(app.mode.rawValue)") + .key("Add.subtitle.bottom"), size: 14, weight: .regular)
        subtitle.alignment = .center
        subtitle.textColor = .init(white: 1, alpha: 0.4)
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.backgroundColor = .haze
        circle.layer!.cornerRadius = 30
        
        let available = Label("\(app.session.available)", size: 26, weight: .bold)
        available.textColor = .black
        
        let info = Label(.key("Add.info"), size: 16, weight: .regular)
        info.textColor = .init(white: 1, alpha: 0.7)
        info.alignment = .center
        
        let _confirm = Control(.key("Add.title.\(app.mode.rawValue)"), target: self, action: #selector(confirm))
        _confirm.layer!.backgroundColor = .haze
        _confirm.label.textColor = .black
        self._confirm = _confirm
        
        let _purchases = Control(.key("Add.purchases"), target: self, action: #selector(purchases))
        _purchases.layer!.backgroundColor = .haze
        _purchases.label.textColor = .black
        self._purchases = _purchases
        
        let cancel = Control(.key("Add.cancel"), target: self, action: #selector(close))
        cancel.label.textColor = .init(white: 1, alpha: 0.4)
        
        [icon, title, subtitle, circle, available, info, _confirm, _purchases, cancel].forEach {
            contentView!.addSubview($0)
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
        
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        
        circle.widthAnchor.constraint(equalToConstant: 60).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        available.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
        
        info.widthAnchor.constraint(equalToConstant: 280).isActive = true
        info.bottomAnchor.constraint(equalTo: _purchases.topAnchor, constant: -40).isActive = true
        
        _confirm.widthAnchor.constraint(equalToConstant: 200).isActive = true
        _confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        _purchases.widthAnchor.constraint(equalToConstant: 200).isActive = true
        _purchases.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
        
        if app.session.available > 0 {
            info.isHidden = true
            _purchases.isHidden = true
            _purchases.target = nil
            icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
            circle.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 80).isActive = true
        } else {
            _confirm.isHidden = true
            _confirm.target = nil
            icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
            circle.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        }
    }
    
    @objc private func confirm() {
        _confirm.target = nil
        app.session.add(app.mode)
        app.main.project(0)
        close()
    }
    
    @objc private func purchases() {
        _purchases.target = nil
        app.main.shop()
        close()
    }
}
