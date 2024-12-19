//
//  AsyncImageView.swift
//
//
//  Created by Igor Malyarov on 29.06.2024.
//

import SwiftUI

/// A SwiftUI view that asynchronously fetches and displays an image.
///
/// `AsyncImageView` is a generic view that takes an initial image, a view builder closure to create
/// the view for displaying the image, and a fetch closure to asynchronously load the image. When the view
/// appears, it triggers the fetch closure to load the image and updates the view accordingly.
public struct AsyncImageView<ImageView: View>: View {
    
    @State private var image: Image
    
    let imageView: (Image) -> ImageView
    let fetchImage: FetchImage
    
    /// Initialises an `AsyncImageView` with the specified initial image, view builder, and fetch closure.
    ///
    /// - Parameters:
    ///   - initialImage: The initial image to display.
    ///   - imageView: A closure that creates a view for displaying the image.
    ///   - fetchImage: A closure that asynchronously fetches the image.
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
    
    /// Initialises an `AsyncImageView` with the specified initial image and fetch closure, using a `ResizableFit` view for display.
    ///
    /// - Parameters:
    ///   - initialImage: The initial image to display.
    ///   - fetchImage: A closure that asynchronously fetches the image.
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
    
    /// Initialises an `AsyncImageView` with the specified initial image and fetch closure, using an `Image` view for display.
    ///
    /// - Parameters:
    ///   - initialImage: The initial image to display.
    ///   - fetchImage: A closure that asynchronously fetches the image.
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
    
    /// Updates the image by calling the fetch closure.
    ///
    /// This method is called when the view appears. It uses the fetch closure to load the image and updates
    /// the `@State` property `image` on the main thread.
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
