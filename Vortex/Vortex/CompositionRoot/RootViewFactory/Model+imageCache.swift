//
//  Model+imageCache.swift
//  Vortex
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
    
    func generalImageCache() -> ImageCache {
        
        generalImageCache(nil)
    }

    func generalImageCache(_ defaultImage: Image?) -> ImageCache {
        
        .init(
            requestImages: {
               $0.forEach { endpoint in
                    self.action.send(ModelAction.General.DownloadImage.Request(endpoint: endpoint.rawValue))
                }
            },
            imagesPublisher: images,
            fallback: {
                guard let defaultImage else { return ImageCacheFallback.image(forKey:$0) }
                
                return defaultImage
            }
        )
    }
}

private enum ImageCacheFallback {
    
    static func image(forKey key: ImageCache.ImageKey) -> Image {
        
        let image = fallbacks[key] ?? .default
        
        return image
    }
    
    private static let fallbacks: [ImageCache.ImageKey: Image] = [
        "placeholder": .ic24MoreHorizontal,
        "sms": .ic24SmsCode,
        "coins": .ic24Coins,
        "b6e5b5b8673544184896724799e50384": .ic40Goods
    ]
}

private extension Image {
    
    static let `default`: Image = .ic24MoreHorizontal
}
