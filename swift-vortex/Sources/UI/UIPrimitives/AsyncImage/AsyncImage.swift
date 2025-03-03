//
//  AsyncImage.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import Combine
import SwiftUI

public struct AsyncImage: View {
    
    @State private var image: Image
    @StateObject private var publisherHolder: PublisherHolder
    
    private let modify: Modify

    public init(
        image: Image,
        publisher: ImagePublisher,
        modify: @escaping Modify = { $0.resizable() }
    ) {
        self._publisherHolder = .init(wrappedValue: .init(image: image, publisher: publisher))
        self.image = image
        self.modify = modify
    }

    public var body: some View {
        
        modify(image)
            .onReceive(publisherHolder.$image) { image = $0 }
    }

    private class PublisherHolder: ObservableObject {
        
        @Published var image: Image
        
        init(
            image: Image,
            publisher: AnyPublisher<Image, Never>
        ) {
            self.image = image
            publisher
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .assign(to: &$image)
        }
    }
}

public extension AsyncImage {
    
    typealias ImagePublisher = AnyPublisher<Image, Never>
    typealias Modify = (Image) -> Image
}

struct AsyncImage_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AsyncImage(
            image: .init(systemName: "car"),
            publisher: Just(.init(systemName: "house"))
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        )
    }
}
