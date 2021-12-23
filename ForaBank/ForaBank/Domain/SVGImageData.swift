//
//  SVGImageData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

//TODO: implement UIImage property
struct SVGImageData: CustomStringConvertible, Equatable {
    
    let description: String
}

extension SVGImageData: Codable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        description = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
