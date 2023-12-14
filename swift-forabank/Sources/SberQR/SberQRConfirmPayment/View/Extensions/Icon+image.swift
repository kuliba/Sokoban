//
//  Icon+image.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import ForaTools
import SwiftUI

extension Icon {
    
    @ViewBuilder
    var image: Image? {
        
        switch self {
        case let .svg(svg): Image(svg: svg)
        }
    }
    
    @ViewBuilder
    func image(with fallback: Image) -> Image {
        
        switch self {
        case .svg: image ?? fallback
        }
    }
}
