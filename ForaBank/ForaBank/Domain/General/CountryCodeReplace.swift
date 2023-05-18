//
//  CountryCodeReplace.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.05.2023.
//

import Foundation

struct CountryCodeReplace: Equatable {
    
    let from: Character
    let to: String
}

extension Array where Element == CountryCodeReplace {
    
    static let russian: Self = [
        .init(from: "8", to: "7"),
        .init(from: "9", to: "7 9")
    ]
    
    static let armenian: Self = [
        .init(from: "8", to: "7"),
        .init(from: "3", to: "374")
    ]
    
    static let turkey: Self = [
        .init(from: "8", to: "7"),
        .init(from: "3", to: "374"),
        .init(from: "9", to: "90")
    ]
}
