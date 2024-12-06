//
//  JSONDecoder+Extensions.swift
//  Vortex
//
//  Created by Max Gribov on 21.01.2022.
//

import Foundation

extension JSONDecoder {
    
    static let serverDate: JSONDecoder = {
       
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601)
        
        return decoder
    }()
}
