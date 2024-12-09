//
//  BottomSheetShutterView.swift
//  
//
//  Created by Andryusina Nataly on 19.09.2023.
//

import SwiftUI

struct BottomSheetShutterView<Content: View>: View {
    
    @Binding var isShutterPresented: Bool
    
    let content: Content
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
            content
                .padding(.top, 29)
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                .overlay(
                    IndicatorView(isShutterPresented: $isShutterPresented)
                        .offset(x: 0, y: -14)
                )
        } else {
            content
                .padding(.top, 29)
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    IndicatorView(isShutterPresented: $isShutterPresented)
                        .offset(x: 0, y: -14)
                )
        }
    }
}
