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
    private let defaultImage: Image
    
    private let imageSubject = PassthroughSubject<Image, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        requestImages: @escaping RequestImages,
        imagesPublisher: ImagesPublisher,
        fallback: @escaping Fallback,
        defaultImage: Image
    ) {
        self.requestImages = requestImages
        self.imagesPublisher = imagesPublisher
        self.fallback = fallback
        self.defaultImage = defaultImage
    }
    
    func image(
        forKey imageKey: ImageKey
    ) -> AnyPublisher<Image, Never> {
        
        let imageID = imageKey.rawValue
        
        // current value
        if let imageData = imagesPublisher.value[imageID],
           let image = imageData.image {
            
            imageSubject.send(image)
            
        } else {
            
            imageSubject.send(fallback(imageKey) ?? defaultImage)
            
            // TODO: add queue to remove duplicated inflight requests
            requestImages([imageKey])
            
            imagesPublisher
                .compactMap { $0[imageID] }
                .compactMap(\.image)
                .removeDuplicates()
                .sink { [weak self] in self?.imageSubject.send($0) }
                .store(in: &cancellables)
        }
        
        return imageSubject.eraseToAnyPublisher()
    }
}
