//
//  Model+imageCache.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.12.2023.
//

extension Model {
    
    func imageCache() -> ImageCache {
        
        .init(
            requestImages: {
                
                self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: $0.map(\.rawValue)))
            },
            imagesPublisher: images
        )
    }
}
