import Foundation
import RezolveSDK

extension SspAct {
    enum ActType {
        case buy, informationPage, regular, unknown
        
        init(isBuy: Bool?, isInformationPage: Bool?) {
            
            switch (isBuy, isInformationPage) {
            case (false, false):
                self = .regular
            case (false, true):
                self = .informationPage
            case (true, false):
                self = .buy
            default:
                self = .unknown
            }
            
        }
    }
    
    var type: ActType {
        return ActType(isBuy: isBuy, isInformationPage: isInformationPage)
    }
}
