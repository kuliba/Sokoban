//
//  AsyncImageViewFactory.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import ForaTools
import SwiftUI

/// A factory class for creating instances of `AsyncImageView` with different fetching strategies.
///
/// `AsyncImageViewFactory` provides methods to create `AsyncImageView` instances that can fetch images
/// using different strategies, such as fetching based on an MD5 hash, named images, or SVG data.
public final class AsyncImageViewFactory<ImageView: View> {
    
    private let placeholder: Image
    private let md5HashFetch: MD5HashFetch
    
    /// Initialises an `AsyncImageViewFactory` with a placeholder image and an MD5 hash fetch closure.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder image to display while the image is being fetched.
    ///   - md5HashFetch: A closure that fetches an image based on an MD5 hash string.
    public init(
        placeholder: Image,
        md5HashFetch: @escaping MD5HashFetch
    ) {
        self.placeholder = placeholder
        self.md5HashFetch = md5HashFetch
    }
    
    /// A type alias for the completion handler used when an image is fetched.
    public typealias ImageCompletion = (Image) -> Void
    
    /// A type alias for the MD5 hash fetch closure.
    ///
    /// The closure takes an MD5 hash string and a completion handler that should be called with the fetched image.
    public typealias MD5HashFetch = (String, @escaping ImageCompletion) -> Void
}

public extension AsyncImageViewFactory {
    
    /// Creates an `AsyncImageView` for the given `AsyncIcon` and image view builder closure.
    ///
    /// - Parameters:
    ///   - icon: The `AsyncIcon` specifying the image fetching strategy.
    ///   - imageView: A closure that creates a view for displaying the image.
    /// - Returns: An `AsyncImageView` configured with the specified icon and image view builder.
    func makeAsyncImageView(
        _ icon: AsyncIcon,
        imageView:  @escaping (Image) -> ImageView
    ) -> AsyncImageView<ImageView> {
        
        switch icon {
        case let .image(image):
            return makeAsyncImageView(with: image, imageView: imageView)
            
        case let .md5Hash(md5Hash):
            return AsyncImageView(
                initialImage: placeholder,
                imageView: imageView,
                fetchImage: { [md5HashFetch] in md5HashFetch(md5Hash, $0) }
            )
            
        case let .named(name):
            return makeAsyncImageView(with: .init(name), imageView: imageView)
            
        case let .svg(svg):
            return makeAsyncImageView(
                with: .init(svg: svg) ?? placeholder,
                imageView: imageView
            )
        }
    }
}

public extension AsyncImageViewFactory where ImageView == ResizableFit {
    
    /// Creates an `AsyncImageView` for the given `AsyncIcon` using a `ResizableFit` view for display.
    ///
    /// - Parameter icon: The `AsyncIcon` specifying the image fetching strategy.
    /// - Returns: An `AsyncImageView` configured with the specified icon and using `ResizableFit` for display.
    func makeAsyncImageView(
        _ icon: AsyncIcon
    ) -> AsyncImageView<ImageView> {
        
        makeAsyncImageView(icon, imageView: ResizableFit.init)
    }
}

private extension AsyncImageViewFactory {
    
    /// Creates an `AsyncImageView` with the given image and image view builder closure.
    ///
    /// This method is used when no fetch is needed, such as for static images or SVG data.
    ///
    /// - Parameters:
    ///   - image: The image to display.
    ///   - imageView: A closure that creates a view for displaying the image.
    /// - Returns: An `AsyncImageView` configured with the specified image and image view builder.
    func makeAsyncImageView(
        with image: Image,
        imageView:  @escaping (Image) -> ImageView
    ) -> AsyncImageView<ImageView> {
        
        return AsyncImageView(
            initialImage: image,
            imageView: imageView,
            fetchImage: { _ in } // no fetch is needed in case of svg
        )
    }
}

// MARK: - Previews

struct AsyncImageViewFactoryDemo_Previews: PreviewProvider {
    
    private static let factory = AsyncImageViewFactory<ResizableFit>(
        placeholder: .init(systemName: "photo"),
        md5HashFetch: { md5Hash, completion in
            
            let icons = ["star", "heart", "circle"]
            
            for (index, icon) in icons.enumerated() {
                
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + Double(index + 1) * 2
                ) {
                    completion(.init(systemName: icon))
                }
            }
            
        }
    )
    
    static var previews: some View {
        
        VStack {
            
            Group {
                
                factory.makeAsyncImageView(.image(.init(systemName: "photo")))
                factory.makeAsyncImageView(.md5Hash(UUID().uuidString))
                factory.makeAsyncImageView(.named("NO IMAGE IN BUNDLE"))
                factory.makeAsyncImageView(.svg(.redCircleSVG))
            }
            .frame(width: 100, height: 100)
            .border(.green)
        }
    }
}

private extension String {
    
    static let redCircleSVG = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
</svg>
"""
}
