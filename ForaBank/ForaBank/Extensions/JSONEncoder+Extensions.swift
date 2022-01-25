//
//  JSONEncoder+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 21.01.2022.
//

import Foundation

extension JSONEncoder {
    
    static let serverDate: JSONEncoder = {
       
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.utc)
        
        return encoder
    }()
}
