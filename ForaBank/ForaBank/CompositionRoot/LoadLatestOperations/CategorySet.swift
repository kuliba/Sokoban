//
//  CategorySet.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

typealias ServiceCategory = String

enum CategorySet {
    
    case all
    case list([ServiceCategory])
}
