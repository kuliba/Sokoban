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
            backgroundImage: viewModel.backgroundImage
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
                backgroundImage: viewModel.backgroundImage
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onTapGesture(perform: viewModel.onTap)
        }
    }
    
    struct StickerImageView: View {
        
        let backgroundImage: Image
        
        var body: some View {
            
            StickerBackgroundImageView(backgroundImage: backgroundImage)
        }
    }
    
    struct StickerBackgroundImageView: View {
        
        let backgroundImage: Image
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                backgroundImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 164, height: 104)
            }
            .frame(width: 164, height: 104)
            .cornerRadius(12)
        }
    }
}

