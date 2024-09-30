//
//  AbroadType.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 14.09.2023.
//

import Foundation

enum AbroadType: Equatable {
    case orderCard, transfer, sticker, marketShowcase
    case control(CardType)
    case limit(CardType)
}
