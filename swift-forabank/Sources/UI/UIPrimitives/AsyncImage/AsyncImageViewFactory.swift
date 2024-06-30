//
//  AsyncImageViewFactory.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import ForaTools
import SwiftUI

public final class AsyncImageViewFactory<ImageView: View> {
    
    private let placeholder: Image
    private let md5HashFetch: MD5HashFetch
    
    public init(
        placeholder: Image,
        md5HashFetch: @escaping MD5HashFetch
    ) {
        self.placeholder = placeholder
        self.md5HashFetch = md5HashFetch
    }
    
    public typealias ImageCompletion = (Image) -> Void
    public typealias MD5HashFetch = (String, @escaping ImageCompletion) -> Void
}

public extension AsyncImageViewFactory {
    
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
    
    func makeAsyncImageView(
        _ icon: AsyncIcon
    ) -> AsyncImageView<ImageView> {
        
        makeAsyncImageView(icon, imageView: ResizableFit.init)
    }
}

private extension AsyncImageViewFactory {
    
    // if no fetch is needed
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
