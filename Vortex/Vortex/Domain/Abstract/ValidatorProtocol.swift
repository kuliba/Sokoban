//
//  ValidatorProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

protocol ValidatorProtocol {
    
    associatedtype Value
    
    func isValid(value: Value) -> Bool
}
