//
//  FeedWithBottomView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct FeedWithBottomView<Feed: View, Bottom: View>: View {
    
    let feed: () -> Feed
    let backgroundColor: Color
    let bottom: () -> Bottom
    
    private let shape = RoundedRectangle(cornerRadius: 8, style: .circular)
    
    var body: some View {
        
        VStack {
            
            feedView()
                .padding(.horizontal)
            bottom()
        }
    }
    
    private func feedView() -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 16) {
                
                feed()
                    .background(backgroundColor)
                    .clipShape(shape)
            }
        }
    }
}

// MARK: - Previews

struct FeedWithBottomView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FeedWithBottomView(
            feed: {
                
                ForEach(0..<20) {
                    
                    Text("Item #\($0)")
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            },
            backgroundColor: Color.blue.opacity(0.1),
            bottom: {
                
                Text("Bottom View")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.green)
                    .clipShape(Capsule())
            }
        )
        .padding(.horizontal)
    }
}
