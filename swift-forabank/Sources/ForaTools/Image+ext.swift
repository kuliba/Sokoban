//
//  Image+ext.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import Foundation
import SVGKit
import SwiftUI

#if os(iOS)
public extension Image {
    
    init?(svg: String) {
        
        guard
            let data = svg.data(using: .utf8),
            let svgImage = SVGKImage(data: data),
            let uiImage = svgImage.uiImage
        else { return nil }
        
        self.init(uiImage: uiImage)
    }
}
#endif
