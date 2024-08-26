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
        self == .additionalSelfAccOwn ||
        self == .additionalCorporate
    }
    
    var isCorporate: Bool {
        self == .corporate ||
        self == .additionalCorporate ||
        self == .individualBusinessman ||
        self == .individualBusinessmanMain
    }
}
