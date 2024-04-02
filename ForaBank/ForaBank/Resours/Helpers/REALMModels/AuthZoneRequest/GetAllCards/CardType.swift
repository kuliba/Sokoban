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
    
    var isAdditional: Bool {
        self == .additionalOther ||
        self == .additionalSelf ||
        self == .additionalSelfAccOwn
    }
}
