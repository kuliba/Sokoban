//
//  Image+ext.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

#if os(iOS)
import Foundation
import SVGKit
import SwiftUI

public extension Image {
    
    init?(svg: String, retry attempts: Int = 0) {
        
        do {
            self = try retry(attempts: attempts) { try svg.svgImage() }
        } catch { return nil }
    }
}

private extension String {
    
    func svgImage() throws -> Image {
        
        guard
            let data = self.data(using: .utf8),
            let svgImage = SVGKImage(data: data),
            let uiImage = svgImage.uiImage
        else {
            throw NSError(domain: "SVG failure", code: -1)
        }
        
        return .init(uiImage: uiImage)
    }
}
#endif
