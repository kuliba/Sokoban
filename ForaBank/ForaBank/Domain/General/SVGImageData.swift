//
//  SVGImageData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import SVGKit
import UIKit
import SwiftUI

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

extension SVGImageData {
    
    var imageData: Data? { description.data(using: .utf8) }
    var uiImage: UIImage? {
        
        guard let svgImage = SVGKImage(data: imageData) else {
            return nil
        }
        
        return svgImage.uiImage
    }
    
    var image: Image? {
        
        guard let uiImage = uiImage else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
}
