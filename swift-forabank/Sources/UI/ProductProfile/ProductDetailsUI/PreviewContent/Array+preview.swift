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
        .single(.numberMasked),
        .multiple([.expirationDate, .cvvMasked])
    ]
}
