import Foundation
import RezolveSDK

enum ActDetailsCellSection: CaseIterable {
    case images, description, answers, termsConditions
    
    var type: UITableViewCell.Type {
        switch self {
        case .images:
            return SspActImageCell.self
        case .description:
            return SspActDescriptionCell.self
        case .answers:
            return SspActAnswerCell.self
        case .termsConditions:
            return SspActTermsCell.self
        }
    }
    
    var height: CGFloat {
        switch self {
        case .images:
            return 325.0
        case .description:
            return UITableView.automaticDimension
        case .answers:
            return 50
        case .termsConditions:
            return 125
        }
    }
    
    static func getAllCases(for act: SspAct) -> AllCases {
        var actAllCases = self.allCases
        let shouldUseImageSection = !act.images.isNilOrEmpty
        let shouldUseTermsSection = act.type == .regular
        
        let omittedImageSectionIfNeedIt = shouldUseImageSection ? nil : self.images
        let omittedTermsSectionIfNeedIt = shouldUseTermsSection ? nil : self.termsConditions
        
        let omittedSectionsIfAny = [omittedImageSectionIfNeedIt, omittedTermsSectionIfNeedIt].compactMap { $0 }
        
        return actAllCases.removeAll(omittedSectionsIfAny)
    }
}
