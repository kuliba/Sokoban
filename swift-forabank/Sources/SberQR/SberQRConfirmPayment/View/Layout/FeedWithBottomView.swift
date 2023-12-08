//
//  FeedWithBottomView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct FeedWithBottomView<Feed: View, Bottom: View>: View {
    
    let feed: () -> Feed
    // let bottom: (@escaping () -> Void) -> Bottom
    let bottom: () -> Bottom
    
    var body: some View {
        
        VStack {
            
            feedView()
            bottom()
        }
    }
    
    private func feedView() -> some View {
        
        VStack {
            
            ScrollView(showsIndicators: false, content: feed)
        }
    }
}

// MARK: - Previews

@available(iOS 15.0, *)
struct FeedWithBottomView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FeedWithBottomView {
            
            ForEach(0..<20) {
                
                Text("Item #\($0)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.gray.opacity(0.2))
                    )
            }
            
        } bottom: {
            
            Text("Bottom View")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.green)
                .clipShape(Capsule())
        }
        .padding(.horizontal)
    }
}
