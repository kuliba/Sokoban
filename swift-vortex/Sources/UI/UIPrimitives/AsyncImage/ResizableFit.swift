//
//  ResizableFit.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import SwiftUI

/// A SwiftUI view that displays a resizable image, maintaining its aspect ratio to fit within its container.
///
/// `ResizableFit` wraps a given `Image` and ensures that the image is resized proportionally to fit within the available space.
///
/// Usage:
/// ```
/// ResizableFit(image: Image(systemName: "star"))
///     .frame(width: 100, height: 100)
/// ```
///
/// - Parameters:
///   - image: The image to be displayed.
public struct ResizableFit: View {
    
    let image: Image
    
    /// Initialises a `ResizableFit` view with the specified image.
    ///
    /// - Parameter image: The image to be displayed and resized to fit.
    public init(image: Image) {
        
        self.image = image
    }
    
    public var body: some View {
        
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
