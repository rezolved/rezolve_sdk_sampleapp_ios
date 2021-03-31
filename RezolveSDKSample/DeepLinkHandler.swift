import Foundation

final class DeepLinkHandler {
    typealias Handler = (URL) -> ()
    
    private var handler: Handler?
    private var url: URL?
    
    private static let shared = DeepLinkHandler()
    
    private init() {
        
    }
    
    private func handle(url: URL) {
        self.url = url
        notify()
    }
    
    private func observe(handler: @escaping Handler) {
        self.handler = handler
        notify()
    }
    
    private func notify() {
        guard
            let handler = handler,
            let url = url
        else {
            return
        }
        handler(url)
    }
    
    static func handle(url: URL) {
        shared.handle(url: url)
    }
    
    static func observe(handler: @escaping Handler) {
        shared.observe(handler: handler)
    }
}
