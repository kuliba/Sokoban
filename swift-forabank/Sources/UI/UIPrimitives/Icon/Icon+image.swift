//
//  Icon+image.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import ForaTools
import SwiftUI

public extension Icon {
    
    var image: Image? {
        
        switch self {
        case let .svg(svg): Image(svg: svg)
        case let .image(image): image
        }
    }
    

    @ViewBuilder
    func image(orColor color: Color) -> some View {
        
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            color
        }
    }
    
    @ViewBuilder
    func image(withFallback fallback: Image) -> Image {
        
        switch self {
        case .svg, .image: image ?? fallback
        }
    }
}
