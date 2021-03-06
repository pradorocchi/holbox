import UIKit

class Delete: UIViewController {
    final class Project: Delete {
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            name.text = app.session.name(index)
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.name(index))
            app.session.delete(index)
            super.confirm()
        }
    }
    
    final class Card: Delete {
        private let index: Int
        private let list: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int, list: Int) {
            self.index = index
            self.list = list
            super.init()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            name.text = app.session.content(app.project, list: list, card: index)
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.content(app.project, list: list, card: index))
            app.session.delete(app.project, list: list, card: index)
            super.confirm()
        }
    }
    
    final class Task: Delete {
        private let index: Int
        private let list: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int, list: Int) {
            self.index = index
            self.list = list
            super.init()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            name.text = app.session.content(app.project, list: list, card: index)
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.content(app.project, list: list, card: index))
            app.session.delete(app.project, list: list, task: index)
            super.confirm()
        }
    }
    
    final class Grocery: Delete {
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            name.text = app.session.content(app.project, list: 0, card: index) + " " + app.session.content(app.project, list: 1, card: index)
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.content(app.project, list: 0, card: index) + " " + app.session.content(app.project, list: 1, card: index))
            app.session.delete(app.project, grocery: index)
            super.confirm()
        }
    }
    
    final class List: Delete {
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            name.text = app.session.name(app.project, list: index)
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.name(app.project, list: index))
            app.session.delete(app.project, list: index)
            super.confirm()
        }
    }
    
    private weak var name: UILabel!
    private weak var top: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.9)
        
        let base = UIView()
        base.backgroundColor = .black
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer.cornerRadius = 8
        base.layer.borderWidth = 1
        base.layer.borderColor = .haze()
        view.addSubview(base)
        
        let icon = Image("trash")
        view.addSubview(icon)
        
        let title = Label(.key("Delete.title"), .medium(14), .haze())
        view.addSubview(title)
        
        let cancel = Control(.key("Delete.cancel"), self, #selector(close), .clear, .haze(0.7))
        view.addSubview(cancel)
        
        let _confirm = Control(.key("Delete.confirm"), self, #selector(confirm), .haze(), .black)
        view.addSubview(_confirm)
        
        let name = Label("", .regular(14), .haze())
        name.numberOfLines = 2
        view.addSubview(name)
        self.name = name
        
        name.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        name.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 30).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -30).isActive = true

        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 30).isActive = true
        icon.topAnchor.constraint(equalTo: base.topAnchor, constant: 30).isActive = true
        
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 2).isActive = true
        
        base.widthAnchor.constraint(equalToConstant: 220).isActive = true
        base.heightAnchor.constraint(equalToConstant: 220).isActive = true
        base.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        top = base.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: app.main.bounds.height)
        top.isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -10).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        _confirm.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: 10).isActive = true
        _confirm.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        top.constant = 0
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private func confirm() {
        close()
        app.main.refresh()
    }
    
    @objc private final func close() {
        presentingViewController!.dismiss(animated: true)
    }
}
