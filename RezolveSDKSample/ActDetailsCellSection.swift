import Foundation
import RezolveSDK

enum ActDetailsCellSection: CaseIterable {
    case images, description, answers
    
    var type: UITableViewCell.Type {
        switch self {
        case .images:
            return SspActImageCell.self
        case .description:
            return SspActDescriptionCell.self
        case .answers:
            return SspActAnswerCell.self
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
        }

    }
    
    static func getAllCases(for act: SspAct) -> AllCases {
        var actAllCases = self.allCases
        
        let omittedImageSectionIfNeedIt = self.images
        
        let omittedSectionsIfAny = [omittedImageSectionIfNeedIt].compactMap { $0 }
        
        return actAllCases.removeAll(omittedSectionsIfAny)
    }
}
