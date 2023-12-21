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
    
    typealias RequestImages = ([ImageKey]) -> Void
    // TODO: replace with better polymorphic interface instead of CurrentValueSubject and ImageKey as key
    typealias ImagesPublisher = CurrentValueSubject<[String: ImageData], Never>
    typealias Fallback = (ImageKey) -> Image?
    
    private let requestImages: RequestImages
    private let imagesPublisher: ImagesPublisher
    private let fallback: Fallback
    
    init(
        requestImages: @escaping RequestImages,
        imagesPublisher: ImagesPublisher,
        fallback: @escaping Fallback
    ) {
        self.requestImages = requestImages
        self.imagesPublisher = imagesPublisher
        self.fallback = fallback
    }
    
    func image(
        forKey imageKey: ImageKey
    ) -> AnyPublisher<Image, Never> {
        
        let imageID = imageKey.rawValue
        
        // current value or fallback
        if let image = imagesPublisher.value[imageID]?.image ?? fallback(imageKey) {
            
            return Just(image).eraseToAnyPublisher()
            
        } else {
            // TODO: add queue to remove duplicated inflight requests
            requestImages([imageKey])
            
            return imagesPublisher
                .compactMap { $0[imageID] }
                .compactMap(\.image)
                .removeDuplicates()
                .eraseToAnyPublisher()
        }
    }
}
