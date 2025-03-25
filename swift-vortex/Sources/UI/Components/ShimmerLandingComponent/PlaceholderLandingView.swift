//
//  PlaceholderLandingView.swift
//
//
//  Created by Дмитрий Савушкин on 24.03.2025.
//

import SwiftUI
import UIPrimitives

struct PlaceholderLandingView: View {
    
    var body: some View {

        ScrollView {
            
            VStack(spacing: 20) {
                
                ZStack {
                    
                    Color
                        .gray
                        .opacity(0.3)
                    
                    VStack(spacing: 32) {
                        
                        itemsPlaceholderView()
                        itemsPlaceholderView()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                }
                .frame(height: 703)
                
                VStack(spacing: 8) {
                    
                    Color
                        .gray
                        .frame(height: 24)
                        .cornerRadius(90)
                        ._shimmering()
                    
                    VStack(spacing: 16) {
                        
                        optionPlaceholderView()
                        optionPlaceholderView()
                        optionPlaceholderView()
                        optionPlaceholderView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                
                VStack(spacing: 36) {
                    
                    secondItemView()
                    secondItemView()
                    secondItemView()
                    secondItemView()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                
                VStack(spacing: 16) {
                    
                    dropDownPlaceholderView()
                    dropDownPlaceholderView()
                    
                }
                .padding(.horizontal, 16)
                
            }
        }
        .safeAreaInset(edge: .bottom) {
            
            Color.gray
                .frame(height: 56, alignment: .center)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                ._shimmering()
        }
        
    }
    
    @ViewBuilder
    func dropDownPlaceholderView() -> some View {

        HStack {
            
            Color.gray
                .frame(width: 24, height: 24, alignment: .center)
                ._shimmering()
                .cornerRadius(24/2)
            
            Color.gray
                .frame(height: 8)
                .cornerRadius(90)
                ._shimmering()
        }
    }
    
    @ViewBuilder
    func secondItemView() -> some View {
    
        Color.gray
            .frame(height: 24)
            .cornerRadius(90)
            ._shimmering()
    }
    
    @ViewBuilder
    func optionPlaceholderView() -> some View {
    
        HStack(spacing: 16) {
            
            Color.gray
                .frame(width: 40, height: 40, alignment: .center)
                ._shimmering()
                .cornerRadius(40/2)
            
            VStack(spacing: 6) {
                
                Color.gray
                    .frame(height: 14)
                    .cornerRadius(90)
                    ._shimmering()
                
                Color.gray
                    .frame(height: 18)
                    .cornerRadius(90)
                    ._shimmering()
            }
        }
    }
    
    func itemsPlaceholderView() -> some View {
        
        VStack(spacing: 12) {
            
            Color
                .white
                .frame(width: 100, height: 8, alignment: .center)
                .cornerRadius(90)
                ._shimmering()
            
            Color
                .white
                .frame(width: 100, height: 8, alignment: .center)
                .cornerRadius(90)
                ._shimmering()
            
            Color
                .white
                .frame(width: 100, height: 8, alignment: .center)
                .cornerRadius(90)
                ._shimmering()
        }
    }
}

#Preview {
    PlaceholderLandingView()
}
