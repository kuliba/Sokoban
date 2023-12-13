//
//  ImageCache.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import SwiftUI
import Tagged

final class ImageCache {
    
    typealias ImageKey = Tagged<_ImageKey, String>
    enum _ImageKey {}
    
    // TODO: replace with polymorphic interface
    private let model: Model
    private var cancellable: AnyCancellable?
    
    init(model: Model) {
        
        self.model = model
    }
    
    func image(
        forKey imageKey: ImageKey,
        completion: @escaping (Image) -> Void
    ) {
        let imageID = imageKey.rawValue
        
        if let imageData = model.images.value[imageID],
           let image = imageData.image {
            
            completion(image)
            
        } else {
            // TODO: add queue to remove duplicated inflight requests
            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [imageID]))
            
            cancellable = model.images
                .compactMap { $0[imageID] }
                .compactMap(\.image)
                .sink(receiveValue: completion)
        }
    }
}
