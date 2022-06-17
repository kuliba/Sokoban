//
//  OperationEnvironment.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

enum OperationEnvironment: String, Codable, Hashable {
    
    case inside = "INSIDE"
    case outside = "OUTSIDE"
}
