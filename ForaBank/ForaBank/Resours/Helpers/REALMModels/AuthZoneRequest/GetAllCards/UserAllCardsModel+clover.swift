//
//  UserAllCardsModel+clover.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.04.2024.
//

import Foundation
import UIKit

extension UserAllCardsModel {
    
    var cloverImage: UIImage? {
        
        if let cardType {
            let isDark = (background.first?.description == "F6F6F7")
            switch cardType {
            case .main:
                return UIImage(named: isDark ? "ic16MainCardGreyFixed2" : "ic16MainCardWhiteFixed2")
            case .additionalOther, .additionalSelf, .additionalSelfAccOwn:
                return UIImage(named: isDark ? "ic16AdditionalCardGrey" : "ic16AdditionalCardWhite")
            default:
                return nil
            }
        }
        return nil
    }
}
