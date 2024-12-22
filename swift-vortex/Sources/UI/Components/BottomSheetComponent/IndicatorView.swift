//
//  IndicatorView.swift
//  
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

extension BottomSheetShutterView {
    
    struct IndicatorView: View {
        
        @Binding var isShutterPresented: Bool
        
        var body: some View {
            
            VStack {
                
                ZStack {
                    
                    Color.init(white: 1.0, opacity: 0.01)
                    
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 48, height: 5)
                }
                .frame(width: UIScreen.main.bounds.width, height: 44)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.3)) { isShutterPresented = false }
                }
                
                Spacer()
            }
        }
    }
}
