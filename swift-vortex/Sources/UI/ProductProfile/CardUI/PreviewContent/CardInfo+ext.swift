//
//  CardInfo+ext.swift
//  
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import Foundation

extension CardInfo {
    
    static let previewWiggleTrue: Self = .init(
        name: "Card Name",
        owner: "Owner",
        cvvTitle: .init(value: "CVV"),
        cardWiggle:  true,
        fullNumber: .init(value: "4444 4444 4444 4444"),
        numberMasked: .init(value: "4444 **** **** ****"))
    
    static let previewWiggleFalse: Self = .init(
        name: "Card Name",
        owner: "Owner",
        cvvTitle: .init(value: "CVV"),
        cardWiggle: false,
        fullNumber: .init(value: "4444 4444 4444 4444"),
        numberMasked: .init(value: "4444 **** **** ****"))
}
