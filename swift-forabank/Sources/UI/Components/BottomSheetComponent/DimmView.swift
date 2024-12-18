//
//  DimmView.swift
//  
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

extension BottomSheetView {
    
    struct DimmView: View {
        
        @Binding var isShutterPresented: Bool
        @Binding var progress: CGFloat
                
        var body: some View {
            
            Color.black
                .opacity(0.3 * progress)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture { isShutterPresented = false }
        }
    }
}
