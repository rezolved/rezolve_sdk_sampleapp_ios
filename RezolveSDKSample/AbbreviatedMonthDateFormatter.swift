import Foundation

struct AbbreviatedMonthDateFormatter {
    private static var dateFormatter: DateFormatter = {
        let format = "MMM dd yyyy"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = .current
        return formatter
    }()
    
    static func getMonthWithoutDotDateText(currentDate: Date) -> String {
        var text = dateFormatter.string(from: currentDate)
        text = text.replacingOccurrences(of: ".", with: "")
        return text
    }
}
