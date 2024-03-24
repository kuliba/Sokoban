//
//  StickerView.swift
//  CarouselPreview
//
//  Created by Disman Dmitry on 06.03.2024.
//

import SwiftUI

struct StickerView: View {
    
    let viewModel: StickerViewModel
    
    var body: some View {
        
        StickerImageView(
            backgroundImage: viewModel.backgroundImage,
            onHide: viewModel.onHide
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onTapGesture(perform: viewModel.onTap)
    }
}

extension StickerView {
    
    struct StickerViewModel {
        
        let backgroundImage: Image
        
        let onTap: () -> Void
        let onHide: () -> Void
    }
    
    struct StickerView: View {
        
        let viewModel: StickerViewModel
        
        var body: some View {
            
            StickerImageView(
                backgroundImage: viewModel.backgroundImage,
                onHide: viewModel.onHide
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onTapGesture(perform: viewModel.onTap)
        }
    }
    
    struct StickerImageView: View {
        
        let backgroundImage: Image
        let onHide: () -> Void
        
        var body: some View {
            
            StickerBackgroundImageView(backgroundImage: backgroundImage, onHide: onHide)
        }
    }
    
    struct StickerBackgroundImageView: View {
        
        let backgroundImage: Image
        let onHide: () -> Void
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                backgroundImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 164, height: 104)
                
                StickerCloseButtonView(action: onHide)
            }
            .frame(width: 164, height: 104)
            .cornerRadius(12)
        }
    }
    
    struct StickerCloseButtonView: View {
        
        let action: () -> Void
        
        var body: some View {
            
            Button {
                withAnimation { action() }
                
            } label: {
                
                ZStack {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "xmark")
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                }
                .frame(width: 20, height: 20)
            }
            .padding(4)
        }
    }
}

