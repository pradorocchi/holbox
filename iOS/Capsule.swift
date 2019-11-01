import UIKit

final class Capsule: UIView {
    weak var target: AnyObject?
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
        base.layer.cornerRadius = 14
        addSubview(base)
        
        let label = Label(title, 12, .bold, text)
        label.isAccessibilityElement = false
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 28).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 15).isActive = true
        label.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -15).isActive = true
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
            _ = target?.perform(action)
        }
        super.touchesEnded(touches, with: with)
    }
}
