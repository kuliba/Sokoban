//
//  ProductView.swift
//  
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import Foundation
import SwiftUI

//MARK: - View

struct ProductView: View {
    
    let appearance: Appearance
    let viewModel: ProductViewModel
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            viewModel.main.cardLogo
                .resizable()
                .frame(width: 32, height: 22, alignment: .center)
            
            VStack(alignment: .leading, spacing: 0) {
                
                ProductView.HeaderView(
                    viewModel: viewModel.header,
                    appearance: appearance
                )
                
                Spacer()
                
                mainView()
            }
        }
        .padding(.init(top: 13, leading: 12, bottom: 13, trailing: 16))
        .background(background())
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
    }
    
    private func mainView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 8) {
                
                viewModel.main.paymentSystem
                
                Text(viewModel.main.name)
                    .font(appearance.textFont)
                    .foregroundColor(appearance.textColor)
                    .opacity(0.5)
                
                Spacer()
                
                Text(viewModel.main.balance)
                    .font(appearance.textFont)
                    .foregroundColor(appearance.textColor)
                    .opacity(0.5)
            }
            
            ProductView.FooterView(
                viewModel: viewModel.footer,
                appearance: appearance
            )
        }
    }
    
    @ViewBuilder
    private func background() -> some View {
        
        if let backgroundImage = appearance.background.image {
            
            backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        } else {
            
            appearance.background.color
        }
    }
}

//MARK: - Internal Views

extension ProductView {
    
    struct HeaderView: View {
        
        let viewModel: ProductViewModel.HeaderViewModel
        let appearance: Appearance
        
        var body: some View {
            
            Text(viewModel.title)
                .font(appearance.textFont)
                .foregroundColor(appearance.textColor)
        }
    }
    
    struct FooterView: View {
        
        let viewModel: ProductViewModel.FooterViewModel
        let appearance: Appearance
        
        var body: some View {
            
            Text(viewModel.description)
                .font(appearance.textFont)
                .fontWeight(.semibold)
                .foregroundColor(appearance.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        @ViewBuilder
        private func overlay(paymentSystem: Image?) -> some View {
            
            if let paymentSystem {
                
                paymentSystem
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(appearance.textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

//MARK: Appearance

extension ProductView {
    
    struct Appearance {
        
        let textColor: Color
        let textFont: Font
        let background: Background
        
        struct Background {
            
            let color: Color
            let image: Image?
        }
    }
}

extension ProductView.Appearance {
    
    static let `default`: Self = .init(
        textColor: .accentColor,
        textFont: .body,
        background: .init(color: .yellow, image: nil)
    )
}

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ProductView(appearance: .default, viewModel: .init(
            header: .init(title: "Счет списания"),
            main: .init(
                cardLogo: .init(""),
                paymentSystem: nil,
                name: "Gold",
                balance: "625 193 Р"
            ),
            footer: .init(description: "description")
        ))
    }
}
