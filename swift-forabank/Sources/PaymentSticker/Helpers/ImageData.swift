//
//  ImageData.swift
//  
//
//  Created by Дмитрий Савушкин on 13.11.2023.
//

import Foundation
import UIKit
import SwiftUI

public struct ImageData: Codable, Equatable, Hashable {

    let data: Data
    
    public init(data: Data) {
        
        self.data = data
    }

    public init?(with uiImage: UIImage) {
        
        guard let pngImageData = uiImage.pngData() else {
           return nil
        }
        
        self.data = pngImageData
    }
    
    public init?(with svgImageData: SVGImageData) {
        
        guard let uiImage = svgImageData.uiImage else {
           return nil
        }
        
        self.init(with: uiImage)
    }
    
    init?(named: String) {
        
        guard let uiImage = UIImage(named: named) else {
           return nil
        }
        
        self.init(with: uiImage)
    }
}

extension ImageData {
    
    var uiImage: UIImage? { UIImage(data: data) }
    var image: Image? {
        
        guard let uiImage = uiImage else {
            return nil
        }
 
        return Image(uiImage: uiImage)
    }
    
    var jpegData: Data? {
        
        self.uiImage?.jpegData(compressionQuality: 1.0)
    }
}

extension ImageData {
    
    static let empty = ImageData(data: Data())
}

 //MARK: Helpers

extension [String: ImageData] {
    
    func imageDataMapper() -> [(id: String, image: ImageData)] {
        
        self.map( { (id: $0.key, image: $0.value) } )
    }
}

public struct SVGImageData: CustomStringConvertible, Equatable, Hashable {

    public let description: String
    
    internal init(description: String) {
        
        self.description = description
    }
    
    init?(data: Data) {
        
        guard let description = String(data: data, encoding: .utf8)  else {
            return nil
        }
        
        self.description = description
    }
}

extension SVGImageData: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        description = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension SVGImageData {
    
    var imageData: Data? { description.data(using: .utf8) }
    var uiImage: UIImage? {
        
        guard let imageData = imageData, let svgImage = UIImage(data: imageData) else {
            return nil
        }
        
        return svgImage
    }
    
    var image: Image? {
        
        guard let uiImage = uiImage else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    //TODO: ImageData
}
