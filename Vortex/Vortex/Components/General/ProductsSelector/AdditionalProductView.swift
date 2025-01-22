//
//  AdditionalProductView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.01.2025.
//

import SwiftUI

struct AdditionalProductViewModel {
    
    let backgroundImage: Image
    let productType: ProductType
    
    let onTap: () -> Void
    let onHide: () -> Void
}

struct AdditionalProductView: View {
    
    let viewModel: AdditionalProductViewModel
    
    var body: some View {
        
        productView()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onTapGesture(perform: viewModel.onTap)
    }
    
    func productView() -> some View {
        
        HStack {
            backgroundImageView()
            dividerView()
        }
    }
    
    func backgroundImageView() -> some View {
        ZStack(alignment: .topTrailing) {
            viewModel.backgroundImage
                .resizable()
                .scaledToFill()
                .frame(width: 164, height: 104)
            
            closeButtonView()
        }
        .frame(width: 164, height: 104)
        .cornerRadius(12)
    }
    
    func dividerView() -> some View {
        
        Capsule(style: .continuous)
            .foregroundColor(.bordersDivider)
            .frame(width: 1, height: 104 / 2)
    }
    
    func closeButtonView() -> some View {
        
        Button {
            withAnimation { viewModel.onHide() }
        } label: {
            
            ZStack {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
                
                Image.ic16Close
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
            }
            .frame(width: 20, height: 20)
        }
        .padding(4)
    }
}

// MARK: - Previews

#Preview {
    AdditionalProductView(
        viewModel: .init(
            backgroundImage: .cardPlaceholder, 
            productType: .card,
            onTap: {
                print("onTap")
            }, 
            onHide: {
                print("onHide")
            })
    )
}
