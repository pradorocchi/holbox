import UIKit

final class Detail: View {
    private weak var scroll: Scroll!
    private weak var height: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.right.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        height = scroll.bottom.constraint(equalTo: scroll.top)
        height.isActive = true
        
        DispatchQueue.main.async { [weak self] in
            self?.refresh()
        }
    }
    
    override func rotate() {
        order()
        scroll.contentOffset.y = 0
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        app.session.projects(app.main.bar.find.filter).enumerated().forEach {
            let item = Project($0.1, order: $0.0)
            scroll.add(item)
            item.top = item.topAnchor.constraint(equalTo: scroll.top)
            item.left = item.leftAnchor.constraint(equalTo: scroll.left)
        }
        order()
    }
    
    private func order() {
        let size = superview!.safeAreaLayoutGuide.layoutFrame.width + 5
        let count = Int(size) / 185
        let margin = (size - (.init(count) * 185)) / 2
        var top = CGFloat(15)
        var left = margin
        var counter = 0
        scroll.views.map { $0 as! Project }.sorted { $0.order < $1.order }.forEach {
            if counter >= count {
                counter = 0
                left = margin
                top += 225
            }
            $0.top.constant = top
            $0.left.constant = left
            left += 185
            counter += 1
        }
        height.constant = top + 235
    }
}
