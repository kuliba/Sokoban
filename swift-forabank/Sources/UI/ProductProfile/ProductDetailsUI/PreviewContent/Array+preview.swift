//
//  Array+preview.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

public extension Array where Element == ListItem {
    
    static let accountItems: Self = [
        .single(.payee),
        .single(.accountNumber),
        .single(.bic),
        .single(.corrAccount),
        .multiple([.inn, .kpp])
    ]
    
    static let cardItems: Self = [
        .single(.holder),
        .single(.number),
        .multiple([.expirationDate, .cvvMasked])
    ]
    
    static let cardItemsWithInfo: Self = [
        .single(.holder),
        .single(.number),
        .multiple([.expirationDate, .info])
    ]
}
