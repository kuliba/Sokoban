//
//  Image+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 26.02.2022.
//

import Foundation
import UIKit
import SwiftUI

extension Image {
    
    init?(data: Data) {
        
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        self.init(uiImage: uiImage)
    }
    
    static func combineImages(images: [UIImage]) -> Image? {
        
        guard !images.isEmpty else { return nil }
        
        if images.count > 1 {
            
            let width: CGFloat = images.map(\.size.width).reduce(0, +)
            let height: CGFloat = images.map(\.size.height).max(by: { (a, b) -> Bool in
                return a < b
            })!
            
            let size = CGSize(width: width, height: height)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            
            var x: CGFloat = 0
            images.forEach {
                $0.draw(in: CGRect(
                    x: x,
                    y: 0,
                    width: $0.size.width,
                    height: height)
                )
                x += $0.size.width
            }

            guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            UIGraphicsEndImageContext()
            
            return Image(uiImage: result)
        } else {
            return Image(uiImage: images.first!)
        }
    }
}

extension Image {
    
    static var cardPlaceholder: Image { Image(#function) }
}
