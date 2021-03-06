import UIKit

final class Control: UIView {
    weak var target: AnyObject!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String, _ target: AnyObject, _ action: Selector, _ background: UIColor, _ text: UIColor) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.backgroundColor = background
        base.layer.cornerRadius = 8
        addSubview(base)
        
        let label = Label(title, .medium(12), text)
        label.isAccessibilityElement = false
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 28).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 0.3
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 1
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 1
        if bounds.contains(touches.first!.location(in: self)) {
            _ = target.perform(action, with: self)
        }
        super.touchesEnded(touches, with: with)
    }
}
