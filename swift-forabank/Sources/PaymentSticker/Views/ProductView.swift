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
    let viewModel: ProductStateViewModel
    
    var body: some View {
        
        VStack {
            
            switch viewModel.state {
            case let .selected(productViewModel):
                selectProductView(productViewModel)
                
            case let .list(productViewModel, productList):
                
                selectProductView(productViewModel)
                optionsList(productList)
            }
        }
        .background(background())
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
    }
    
    private func optionsList(
        _ productList: [ProductViewModel]
    ) -> some View {
    
        HStack(spacing: 10) {
        
            ScrollView {
             
                ForEach(productList, id: \.self) { product in
                        
                    productOption(
                        product: product,
                        header: product.header
                    )
                }
            }
        }
    }
    
    private func productOption(
        product: ProductViewModel,
        header: ProductViewModel.HeaderViewModel
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ProductView.HeaderView(
                viewModel: header,
                appearance: .default
            )
            .padding(.leading, 10)
            .padding(.top, 4)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(product.main.name)
                    .font(.body)
                    .foregroundColor(.black)
                    .opacity(0.5)
                
                ProductView.FooterView(
                    viewModel: product.footer,
                    appearance: .default
                )
            }
        }
        .background(background())
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
        .onTapGesture {
            
        }
    }
    
    private func selectProductView(
        _ productViewModel: ProductViewModel
    ) -> some View {
        
        HStack(spacing: 12) {
            
            Image(productViewModel.main.cardLogo)
                .resizable()
                .frame(width: 32, height: 22, alignment: .center)
            
            VStack(alignment: .leading, spacing: 0) {
                
                ProductView.HeaderView(
                    viewModel: productViewModel.header,
                    appearance: appearance
                )
                
                Spacer()
                
                mainView(
                    productViewModel,
                    chevronTapped: viewModel.chevronTapped
                )
            }
        }
        .padding(.init(top: 13, leading: 12, bottom: 13, trailing: 16))
    }
    
    private func mainView(
        _ viewModel: ProductViewModel,
        chevronTapped: @escaping () -> Void
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 8) {
                
                if let imageName = viewModel.main.paymentSystem {
                    
                    Image(imageName)
                }
                
                Text(viewModel.main.name)
                    .font(appearance.textFont)
                    .foregroundColor(appearance.textColor)
                    .opacity(0.5)
                
                Spacer()
                
                Text(viewModel.main.balance)
                    .font(appearance.textFont)
                    .foregroundColor(appearance.textColor)
                    .opacity(0.5)
                
                Image(systemName: "chevron.down")
                    .onTapGesture(perform: chevronTapped)
                
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
        
        ProductView(
            appearance: .default,
            viewModel: .init(
                state: .selected(.init(
                    header: .init(title: "Счет списания"),
                    main: .init(
                        cardLogo: .init(""),
                        paymentSystem: nil,
                        name: "Gold",
                        balance: "625 193 Р"
                    ),
                    footer: .init(description: "description")
                )),
                chevronTapped: {},
                selectOption: { _ in })
        )
        .frame(height: 80)
        .padding(20)
    }
}
