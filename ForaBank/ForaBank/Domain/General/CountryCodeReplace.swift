//
//  CountryCodeReplace.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 18.05.2023.
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
