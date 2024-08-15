//
//  CardType.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.04.2024.
//

import Foundation

enum CardType: Codable {
    
    case main
    case regular
    case additionalSelf
    case additionalSelfAccOwn
    case additionalOther
    
    case additionalCorporate
    case corporate
    case individualBusinessman
    case individualBusinessmanMain

    var isAdditional: Bool {
        self == .additionalOther ||
        self == .additionalSelf ||
        self == .additionalSelfAccOwn
    }
    
    func cardTypeForRequest(
        _ cardType: ProductCardData.CardType
    ) -> CardType {
        switch cardType {
        case .main:
            return .main
        case .regular:
            return .regular
        case .additionalSelf:
            return .additionalSelf
        case .additionalSelfAccOwn:
            return .additionalSelfAccOwn
        case .additionalOther:
            return .additionalOther
        case .additionalCorporate:
            return .additionalCorporate
        case .corporate:
            return .corporate
        case .individualBusinessman:
            return .individualBusinessman
        case .individualBusinessmanMain:
            return .individualBusinessmanMain
        }
    }
}
