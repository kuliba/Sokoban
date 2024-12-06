//
//  ImageCache.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import ForaTools
import RxViewModel
import Tagged
import SwiftUI

final class ImageCache {
    
    typealias ImageKey = Tagged<_ImageKey, String>
    enum _ImageKey {}
    
    typealias RequestImages = ([ImageKey]) -> Void
    // TODO: replace with better polymorphic interface instead of CurrentValueSubject and ImageKey as key
    typealias ImagesPublisher = CurrentValueSubject<[String: ImageData], Never>
    typealias Fallback = (ImageKey) -> Image
    typealias ImageSubject = CurrentValueSubject<Image, Never>
    
    private let requestImages: RequestImages
    private let imagesPublisher: ImagesPublisher
    private let fallback: Fallback
    
    private let scheduler: AnySchedulerOfDispatchQueue
    private var cancellable: AnyCancellable?
    
    init(
        requestImages: @escaping RequestImages,
        imagesPublisher: ImagesPublisher,
        fallback: @escaping Fallback,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        self.requestImages = requestImages
        self.imagesPublisher = imagesPublisher
        self.fallback = fallback
        self.scheduler = scheduler
    }
        
    func image(
        forKey imageKey: ImageKey
    ) -> ImageSubject {
        
        let imageID = imageKey.rawValue
        
        // current value
        if let image = imagesPublisher.value[imageID]?.image {
            
            return .init(image)
            
        } else {
            
            // or fallback
            let imageSubject = ImageSubject(fallback(imageKey))
            
            // TODO: add queue to remove duplicated inflight requests
            requestImages([imageKey])
            
            cancellable = imagesPublisher
                .removeDuplicates()
            // .handleEvents(receiveOutput: { print("### imagesPublisher, all", $0) })
                .compactMap { $0[imageID] }
            // .handleEvents(receiveOutput: { print("### imagesPublisher filtered by \(imageID)", $0) })
                .compactMap(\.image)
            // .handleEvents(receiveOutput: { print("### image for \(imageID)", $0) })
                .receive(on: scheduler)
                .sink(receiveValue: imageSubject.send)
            
            return imageSubject
        }
    }
}
