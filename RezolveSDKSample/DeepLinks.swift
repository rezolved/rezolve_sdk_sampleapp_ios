import Foundation

final class DeepLinks {
    typealias Handler = (URL) -> ()
    
    private var handler: Handler?
    private var queue = [URL]()
    
    private static let shared = DeepLinks()
    
    private init() {
        
    }
    
    private func handle(url: URL) {
        queue.append(url)
        notify()
    }
    
    private func observe(handler: @escaping Handler) {
        self.handler = handler
        notify()
    }
    
    private func notify() {
        guard
            let handler = handler,
            let last = queue.popLast()
        else {
            return
        }
        handler(last)
        notify()
    }
    
    static func handle(url: URL) {
        shared.handle(url: url)
    }
    
    static func observe(handler: @escaping Handler) {
        shared.observe(handler: handler)
    }
}
