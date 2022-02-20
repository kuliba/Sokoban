//
//  ImageData.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation
import UIKit
import SwiftUI

struct ImageData {

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
}

extension ImageData {
    
    var uiImage: UIImage? { UIImage(data: data) }
    var image: Image? {
        
        guard let uiImage = uiImage else {
            return nil
        }
 
        return Image(uiImage: uiImage)
    }
}

extension ImageData {
    
    static let empty = ImageData(data: Data())
}
