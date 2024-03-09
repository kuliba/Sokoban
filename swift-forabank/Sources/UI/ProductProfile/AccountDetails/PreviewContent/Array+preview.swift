//
//  Array+preview.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

extension Array where Element == ItemForList {
    
    static let preview: Self = [
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
