//
//  Model+imageCache.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.12.2023.
//

import SwiftUI

extension Model {
    
    func imageCache() -> ImageCache {
        
        .init(
            requestImages: {
                
                self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: $0.map(\.rawValue)))
            },
            imagesPublisher: images,
            fallback: ImageCacheFallback.image(forKey:)
        )
    }
}

private enum ImageCacheFallback {
    
    static func image(forKey key: ImageCache.ImageKey) -> Image {
        
        let image = fallbacks[key] ?? Self.default
        
        return image
    }
    
    private static let `default`: Image = .ic24MoreHorizontal
    
    private static let fallbacks: [ImageCache.ImageKey: Image] = [
        "placeholder": .ic24MoreHorizontal,
        "b6e5b5b8673544184896724799e50384": .ic40Goods
    ]
}
