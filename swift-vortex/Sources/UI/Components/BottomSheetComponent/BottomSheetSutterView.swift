//
//  BottomSheetShutterView.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//


import SwiftUI

public struct BottomSheetShutterView<Content: View>: View {
    
    @Binding var isShutterPresented: Bool
    
    let content: Content
    
    public init(
        isShutterPresented: Binding<Bool>,
        content: Content
    ) {
        self._isShutterPresented = isShutterPresented
        self.content = content
    }
    
    public var body: some View {
        
        content
            .padding(.top, 29)
            .frame(width: UIScreen.main.bounds.width)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            .overlay(
                IndicatorView(isShutterPresented: $isShutterPresented)
                    .offset(x: 0, y: -14)
            )
    }
}
