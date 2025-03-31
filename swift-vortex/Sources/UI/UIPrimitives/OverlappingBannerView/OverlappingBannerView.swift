//
//  OverlappingBannerView.swift
//
//
//  Created by Igor Malyarov on 29.03.2025.
//

import SwiftUI

/// A container view that overlaps content on top of a banner view with a configurable vertical offset.
/// The `overlap` parameter defines how far the content is offset from the top of the banner.
/// A positive value moves the content upward relative to the banner's bottom edge.
///
/// Example usage:
/// ```swift
/// OverlappingBannerView(
///     overlap: 54,
///     banner: {
///         Color.orange.frame(height: 400)
///     },
///     content: {
///         VStack { … }
///     }
/// )
/// ```
///
/// - Parameters:
///   - overlap: The vertical offset applied to the content relative to the banner's bottom.
///   - banner: A closure that returns the banner view. This closure is evaluated once during initialization.
///   - content: A closure that returns the overlapping content view. This closure is evaluated once during initialization.
/// - Note: Using closures instead of @ViewBuilder is intentional to ensure a predictable stacking order.
public struct OverlappingBannerView<Banner: View, Content: View>: View {
    
    private let overlap: CGFloat
    private let banner: Banner
    private let content: Content
    
    /// Initializes the OverlappingBannerView.
    /// - Parameters:
    ///   - overlap: The vertical offset for the overlapping content.
    ///   - banner: A closure returning the banner view.
    ///   - content: A closure returning the overlapping content.
    public init(
        overlap: CGFloat,
        banner: () -> Banner,
        content: () -> Content
    ) {
        self.overlap = overlap
        self.banner = banner()
        self.content = content()
    }
    
    public var body: some View {
        
        ZStack(alignment: .bannerBottom) {
            
            banner
                .alignmentGuide(.bannerBottom) { $0[.bottom] }
            
            // The content view is shifted upward by `overlap` points relative to the banner’s bottom.
            content
                .alignmentGuide(.bannerBottom) { $0[.top] + overlap }
        }
    }
}

// MARK: - Previews

#Preview {
    
    ScrollView {
        
        OverlappingBannerView(
            overlap: 54,
            banner: {
                
                // Banner view: a simple orange-colored banner.
                Color.orange
                    .frame(height: 400)
            },
            content: {
                
                // Overlaid content including a call-to-action button and a list of text views.
                VStack {
                    
                    Button("Call to Action") {
                        // your action here
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    
                    ForEach(0..<20) { index in
                        Text("Other content \(index)")
                            .padding(.vertical, 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(Material.thin)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            }
        )
    }
    .ignoresSafeArea(.container, edges: .top)
}
