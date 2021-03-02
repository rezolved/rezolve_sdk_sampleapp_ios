import Foundation
import RezolveSDK

protocol SspActViewModelDelegate: class {
    func display(items: [SspActItem])
}

final class SspActViewModel {
    private var page: Page!
    let sspAct: SspAct
    
    weak var delegate: SspActViewModelDelegate?
    
    init(sspAct: SspAct) {
        self.sspAct = sspAct
    }
    
    func loadPage() {
        guard let form = sspAct.pageBuildingBlocks else {
            return
        }
        page = PageBuilder().buildIgnoringErros(elements: form)
        let items: [SspActItem] = page.elements.map({ .pageElement($0) })
        delegate?.display(items: items)
        validatePage()
    }
    
    func validatePage() {
        print(page.isValid)
    }
}

enum SspActItem {
    case images([URL])
    case description(SspAct)
    case pageElement(Page.Element)
}
