import Foundation
import RezolveSDK

final class PageElementOptionPicker {
    typealias Completion = (Page.Element.Select.Option) -> Void
    
    func pick(for select: Page.Element.Select, completion: @escaping Completion) {
        let options = select.options.map({ $0.description })
        let payload: [String: Any?] = [
            "data": options,
            "lastDataSelected": select.value?.description,
            "title": select.text,
            "callback": { [weak select] (position: Int) -> Void in
                guard let select = select else {
                    return
                }
                let option = select.options[position]
                completion(option)
            }]
    }
}
