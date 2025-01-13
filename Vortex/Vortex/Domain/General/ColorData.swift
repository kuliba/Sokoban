//
//  ColorData.swift
//  Vortex
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation
import SwiftUI

struct ColorData: CustomStringConvertible, Equatable {
    
    let description: String
}

extension ColorData: Codable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        description = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension ColorData {
    
    var color: Color { Color(hex: description) }
}


