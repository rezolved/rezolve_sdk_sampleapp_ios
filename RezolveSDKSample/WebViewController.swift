import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(
            URLRequest(url: url)
        )
    }
}
