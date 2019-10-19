import AppKit

extension NSColor {
    static let haze = #colorLiteral(red: 0.7137254902, green: 0.7411764706, blue: 1, alpha: 1)
    static let background = #colorLiteral(red: 0.1058823529, green: 0.0862745098, blue: 0.1450980392, alpha: 1)
}

extension CGColor {
    static let haze = NSColor.haze.cgColor
    static let background = NSColor.background.cgColor
}

extension NSImage {
    func tint(_ color: NSColor) -> NSImage {
        let image = copy() as! NSImage
        image.lockFocus()
        color.set()
        NSRect(origin: .init(), size: image.size).fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
}
