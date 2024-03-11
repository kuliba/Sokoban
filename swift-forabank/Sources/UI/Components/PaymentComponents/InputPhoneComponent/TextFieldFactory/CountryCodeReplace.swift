//
//  CountryCodeReplace.swift
//
//
//  Created by Дмитрий Савушкин on 06.03.2024.
//

import Foundation

struct CountryCodeReplace: Equatable {
    
    let from: String
    let to: String
}

extension Array where Element == CountryCodeReplace {
    
    static let russian: Self = [
        .init(from: "89", to: "79")
    ]
}
