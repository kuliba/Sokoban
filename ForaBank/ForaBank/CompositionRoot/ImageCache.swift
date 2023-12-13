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
    
    typealias RequestImages = ([String]) -> Void
    // TODO: replace with better polymorphic interface
    typealias ImagesPublisher = CurrentValueSubject<[String: ImageData], Never>

    private let requestImages: RequestImages
    private let imagesPublisher: ImagesPublisher
    
    init(
        requestImages: @escaping RequestImages,
        imagesPublisher: ImagesPublisher
    ) {
        self.requestImages = requestImages
        self.imagesPublisher = imagesPublisher
    }
    
    func image(
        forKey imageKey: ImageKey
    ) -> AnyPublisher<Image, Never> {
        
        let imageID = imageKey.rawValue
        
        if let imageData = imagesPublisher.value[imageID],
           let image = imageData.image {
            
            return Just(image).eraseToAnyPublisher()
            
        } else {
            // TODO: add queue to remove duplicated inflight requests
            requestImages([imageID])
            
            return imagesPublisher
                .compactMap { $0[imageID] }
                .compactMap(\.image)
                .eraseToAnyPublisher()
        }
    }
}
