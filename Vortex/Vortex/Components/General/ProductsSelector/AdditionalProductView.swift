//
//  AdditionalProductView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.01.2025.
//

import Combine
import SwiftUI
import UIPrimitives

struct AdditionalProductViewModel {
    
    let md5Hash: String
    let productType: ProductType
    let promoItem: PromoItem
    
    let onTap: () -> Void
    let onHide: () -> Void
}

extension AdditionalProductViewModel: Identifiable {
    
    public var id: ID {
        
        switch promoItem.promoProduct {
        case .creditCardMVP:  return .creditCardMVP
        case .savingsAccount: return .savingsAccount
        case .sticker:        return .sticker
        }
    }
    
    public enum ID: Hashable {
        
        case creditCardMVP, savingsAccount, sticker
    }
}

struct AdditionalProductView: View {
    
    let viewModel: AdditionalProductViewModel
    let makeIconView: MakeIconView
    
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
            makeIconView(.md5Hash(.init(viewModel.md5Hash)))
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
            md5Hash: "dsdsd",
            productType: .card,
            promoItem: .savingsAccountPreview,
            onTap: { print("onTap") },
            onHide: { print("onHide") }
        ),
        makeIconView: { _ in .init(
            image: .cardPlaceholder,
            publisher: Just(.cardPlaceholder).eraseToAnyPublisher()
        )}
    )
}
