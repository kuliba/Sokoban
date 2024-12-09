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
    
    private let publisher: ImagePublisher
    private let modify: Modify
    
    public init(
        image: Image,
        publisher: ImagePublisher,
        _ modify: @escaping Modify = { $0.resizable() }
    ) {
        self.image = image
        self.publisher = publisher
        self.modify = modify
    }
    
    public var body: some View {
        
        modify(image)
            .onReceive(publisher) { self.image = $0 }
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
