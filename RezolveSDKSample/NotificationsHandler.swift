import RezolveSDK

final class NotificationsHandler {
    typealias Handler = (EngagementNotification) -> ()
    
    private var handler: Handler?
    private var notification: EngagementNotification?
    
    private static let shared = NotificationsHandler()
    
    private init() {
        
    }
    
    private func handle(userInfo: [AnyHashable : Any]) {
        guard let content = userInfo as? [String : Any] else {
            return
        }
        do {
            notification = try EngagementNotification(userInfo: content)
            notify()
        } catch {
            debugPrint(error)
        }
    }
    
    private func observe(handler: @escaping Handler) {
        self.handler = handler
        notify()
    }
    
    private func notify() {
        guard
            let handler = handler,
            let notification = notification
        else {
            return
        }
        handler(notification)
    }
    
    static func handle(userInfo: [AnyHashable : Any]) {
        shared.handle(userInfo: userInfo)
    }
    
    static func observe(handler: @escaping Handler) {
        shared.observe(handler: handler)
    }
}
