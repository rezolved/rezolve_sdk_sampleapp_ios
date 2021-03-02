import Foundation
import RezolveSDK

final class DatePicker {
    typealias Completion = (Date) -> Void
    
    func pick(for dateField: Page.Element.DateField, completion: @escaping Completion) {
        pick(
            title: dateField.text,
            selectedDate: dateField.value,
            minDate: dateField.minDate,
            maxDate: dateField.maxDate,
            completion: completion
        )
    }
    
    func pick(title: String?, selectedDate: Date?, minDate: Date?, maxDate: Date?, completion: @escaping Completion) {
        let payload: [String: Any?] = [
            "title": title,
            "value": selectedDate,
            "minDate": minDate,
            "maxDate": maxDate,
            "callback": completion
        ]
    }
}
