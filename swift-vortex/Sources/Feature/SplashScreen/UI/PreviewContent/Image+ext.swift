//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI
import VortexTools

extension Image {
    
    static let morning = jpeg(named: "MORNING2")
    
    private static func jpeg(
        named name: String
    ) -> Image {

        let ext = "jpg"
        
        // `Image(name, bundle: .module)` does not work in preview
        guard
            let url = Bundle.module.url(forResource: name, withExtension: ext),
            let data = try? Data(contentsOf: url),
            let uiImage = UIImage(data: data)
        else {
            
            print("Can't create image \"\(name).\(ext)\"")
            return .init(systemName: "star")
        }
        
        return .init(uiImage: uiImage)
    }
    
    static func svg(
        svgString: String
    ) -> Image {

        guard let image = Image(svg: svgString, retry: 1) else {
            
            print("Can't create image \"\(svgString)\"")
            return .init(systemName: "star")
        }
        
        return image
    }
}
