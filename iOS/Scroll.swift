import UIKit

final class Scroll: UIScrollView, UIScrollViewDelegate {
    var views: [UIView] { content.subviews }
    var top: NSLayoutYAxisAnchor { content.topAnchor }
    var bottom: NSLayoutYAxisAnchor { content.bottomAnchor }
    var left: NSLayoutXAxisAnchor { content.leftAnchor }
    var right: NSLayoutXAxisAnchor { content.rightAnchor }
    var centerX: NSLayoutXAxisAnchor { content.centerXAnchor }
    var centerY: NSLayoutYAxisAnchor { content.centerYAnchor }
    var width: NSLayoutDimension { content.widthAnchor }
    var height: NSLayoutDimension { content.heightAnchor }
    private(set) weak var content: UIView!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        alwaysBounceVertical = true
        clipsToBounds = true
        delegate = self
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.clipsToBounds = true
        content.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(content)
        self.content = content
        
        content.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        content.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        content.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        content.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    func add(_ view: UIView) { content.addSubview(view) }
    
    func scrollViewWillBeginDragging(_: UIScrollView) {
        app.window!.endEditing(true)
    }
    
    func center(_ frame: CGRect) {
        var frame = frame
        frame.origin.x -= (bounds.width - frame.size.width) / 2
        frame.origin.y -= ((bounds.height - frame.size.height) / 2) - 45
        frame.size.width = bounds.width
        frame.size.height = bounds.height
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollRectToVisible(frame, animated: true)
        }
    }
}
