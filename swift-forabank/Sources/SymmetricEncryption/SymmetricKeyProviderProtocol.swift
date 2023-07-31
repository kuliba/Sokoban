//
//  SymmetricKeyProviderProtocol.swift
//  
//
//  Created by Max Gribov on 21.07.2023.
//

import Foundation

public protocol SymmetricKeyProviderProtocol {
    
    func getSymmetricKeyRawRepresentation() -> Data
}
