//
//  PlaceholderView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct PlaceholderView: View {
    
    var opacity: Double
    
    var body: some View {
        
        Color.solidGrayBackground
            .opacity(opacity)
            .overlay(LinearGradient.horizontalWhite)
    }
}

extension Color {
    
    // Equivalent to #C4C4C4
    static let solidGrayBackground: Self = .init(white: 0.76)
}

extension LinearGradient {
    
    static let horizontalWhite: Self = .init(
        gradient: Gradient(stops: [
            // corresponds to -43.16%
            .init(color: Color.white, location: -0.4316),
            // corresponds to 122.65%
            .init(color: Color.white.opacity(0), location: 1.2265)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

struct PlaceholderView_previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            components
            
            VStack(spacing: 32) {
                
                placeholders(opacity: 1)
                placeholders(opacity: 0.2)
            }
            ._shimmering()
            .previewDisplayName("Placeholder with shimmering")
        }
    }
    
    private static func placeholders(
        opacity: Double,
        width: CGFloat = 150
    ) -> some View {
        
        HStack(spacing: 32) {
            
            Group {
                
                PlaceholderView(opacity: opacity)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                
                PlaceholderView(opacity: opacity)
                    .clipShape(Circle())
            }
            .frame(width: width, height: width)
        }
    }
    
    private static var components: some View {
        
        VStack(spacing: 32) {
            
            HStack(spacing: 32) {
                
                Group {
                    
                    Color.solidGrayBackground
                        .overlay(LinearGradient.horizontalWhite)
                    
                    PlaceholderView(opacity: 0.2)
                }
                .clipShape(Circle())
                .frame(width: 150, height: 150)
            }
            .frame(maxHeight: .infinity)
            
            HStack(spacing: 32) {
                
                Group {
                    
                    Color.solidGrayBackground
                    
                    LinearGradient.horizontalWhite
                }
                .clipShape(Rectangle())
                .frame(width: 150, height: 150)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
        }
        .ignoresSafeArea()
    }
}
