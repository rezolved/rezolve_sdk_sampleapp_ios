import Foundation
import RezolveSDK

protocol SspActViewModelDelegate: class {
    func display(items: [SspActItem])
    func enableSubmitView(isEnabled: Bool)
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
        var items: [SspActItem] = page.elements.map({ .pageElement($0) })
        if sspAct.isInformationPage == false {
            items.append(.terms)
        }
        delegate?.display(items: items)
        validatePage()
    }
    
    func validatePage() {
        delegate?.enableSubmitView(isEnabled: page.isValid)
    }
    
    func submit(sspActManager: SspActManager, location: CLLocation?) {
        let handler = UserSspActSubmissionHandler(
            sspActManager: sspActManager,
            sspAct: sspAct,
            answers: .page(page),
            location: location
        )
        
        handler.submitAct { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let submission):
                print("*** Success")
            case .failure(let error):
                print("*** Error")
            }
        }
    }
}

enum SspActItem {
    case images([URL])
    case description(SspAct)
    case pageElement(Page.Element)
    case terms
}
