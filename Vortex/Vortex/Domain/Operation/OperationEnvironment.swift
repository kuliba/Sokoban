//
//  OperationEnvironment.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

enum OperationEnvironment: String, Codable, Hashable, Unknownable {
    
    case inside = "INSIDE"
    case outside = "OUTSIDE"
    case unknown
}
