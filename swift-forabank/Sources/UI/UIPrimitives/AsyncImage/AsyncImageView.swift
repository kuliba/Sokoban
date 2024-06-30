//
//  AsyncImageView.swift
//
//
//  Created by Igor Malyarov on 29.06.2024.
//

import SwiftUI

public struct AsyncImageView<ImageView: View>: View {
    
    @State private var image: Image
    
    let imageView: (Image) -> ImageView
    let fetchImage: FetchImage
    
    public init(
        initialImage: Image,
        imageView: @escaping (Image) -> ImageView,
        fetchImage: @escaping FetchImage
    ) {
        self.image = initialImage
        self.imageView = imageView
        self.fetchImage = fetchImage
    }
    
    public var body: some View {
        
        imageView(image)
            .onAppear(perform: updateImage)
    }
}

public extension AsyncImageView {
    
    typealias FetchImage = (@escaping (Image) -> Void) -> Void
}

public extension AsyncImageView where ImageView == ResizableFit {
    
    init(
        initialImage: Image,
        fetchImage: @escaping FetchImage
    ) {
        self.init(
            initialImage: initialImage,
            imageView: ResizableFit.init,
            fetchImage: fetchImage
        )
    }
}

public extension AsyncImageView where ImageView == Image {
    
    init(
        initialImage: Image,
        fetchImage: @escaping FetchImage
    ) {
        self.init(
            initialImage: initialImage,
            imageView: { $0 },
            fetchImage: fetchImage
        )
    }
}

private extension AsyncImageView {
    
    func updateImage() {
        
        DispatchQueue.main.async {
            
            fetchImage { image = $0 }
        }
    }
}

// MARK: - Previews

private struct AsyncIconViewDemo: View {
    
    @State private var id = UUID()
    
    private let icons = ["star", "heart", "circle"]
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Button("reset") { id = .init() }
            
            AsyncImageView(
                initialImage: .init(systemName: "photo"),
                imageView: imageView,
                fetchImage: { completion in
                    
                    for (index, icon) in icons.enumerated() {
                        
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + Double(index + 1) * 2
                        ) {
                            completion(.init(systemName: icon))
                        }
                    }
                }
            )
            .frame(width: 100, height: 100)
        }
        .id(id)
    }
    
    private func imageView(
        image: Image
    ) -> some View {
        
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    AsyncIconViewDemo()
}
