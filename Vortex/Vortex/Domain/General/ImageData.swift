//
//  ImageData.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation
import UIKit
import SwiftUI

struct ImageData: Codable, Equatable, Hashable {

    let data: Data
    
    internal init(data: Data) {
        
        self.data = data
    }

    init?(with uiImage: UIImage) {
        
        guard let pngImageData = uiImage.pngData() else {
           return nil
        }
        
        self.data = pngImageData
    }
    
    init?(with svgImageData: SVGImageData) {
        
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
        
        if let uiImage = uiImage {
            
            return Image(uiImage: uiImage)
        }
        
        if let svg = SVGImageData(data: data) {
            
            return svg.image
        }
 
        return nil
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
