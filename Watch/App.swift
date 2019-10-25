import holbox
import WatchKit

private(set) weak var app: App!
final class App: NSObject, WKExtensionDelegate {
    var awoke = false
    let global = Global()
    
    override init() {
        super.init()
        app = self
    }
    
    func applicationDidFinishLaunching() {
        if global.session == nil {
            Session.load {
                self.global.session = $0
            }
        }
    }
    
    func applicationDidEnterBackground() {
        awoke = true
    }
    
    func refresh() {
        if awoke {
            awoke = false
            if let session = global.session {
                global.session = nil
                session.refresh {
                    self.global.session = session
                }
            }
        }
    }
}
