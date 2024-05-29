//
//  ProductView.swift
//  
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import Foundation
import SwiftUI

//MARK: - View

public struct ProductView: View {
    
    let appearance: Appearance
    let viewModel: ProductStateViewModel
    
    public var body: some View {
        
        VStack(spacing: 10) {
            
            switch viewModel.state {
            case let .selected(productViewModel):
                selectProductView(productViewModel, state: viewModel.state)
                
            case let .list(productViewModel, productList):
                
                selectProductView(productViewModel, state: viewModel.state)
                    .onTapGesture(perform: viewModel.chevronTapped)
                
                optionsList(
                    productList,
                    viewModel: viewModel,
                    optionConfig: appearance.optionConfig
                )
            }
        }
        .background(appearance.background.color)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
    }
    
    private func optionsList(
        _ productList: [ProductViewModel],
        viewModel: ProductStateViewModel,
        optionConfig: Appearance.OptionConfig
    ) -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 10) {
                
                ForEach(productList, id: \.self) { product in
                   
                    ZStack(alignment: .topTrailing) {
                        
                        VStack(spacing: 8) {
                            
                            HStack {
                                
                                Color.clear
                                    .frame(width: 20, height: 20, alignment: .center)
                                
                                Text(product.footer.description)
                                    .font(optionConfig.numberFont)
                                    .foregroundColor(optionConfig.numberColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            VStack(spacing: 4) {
                                
                                Text(product.main.name)
                                    .font(optionConfig.nameFont)
                                    .foregroundColor(optionConfig.nameColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    
                                    Text(product.main.balance)
                                        .font(optionConfig.balanceFont)
                                        .foregroundColor(optionConfig.balanceColor)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.init(top: 12, leading: 8, bottom: 8, trailing: 8))
                        .background(background(product))
                        .frame(width: 112, height: 71)
                        .cornerRadius(8)
                        .onTapGesture {
                            
                            viewModel.selectOption(product)
                        }
                        
                        cloverView(product)
                    }
                }
            }
        }
        .padding(10)
    }
    
    @ViewBuilder
    private func cloverView(
        _ product: ProductViewModel
    ) -> some View {
        
        if let data = product.main.clover?.data {
            Image(data: data)
                .resizable()
                .frame(width: 14, height: 14, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .padding(.top, 9)
                .padding(.trailing, 10)
        }
    }
    
    private func selectProductView(
        _ productViewModel: ProductViewModel,
        state: ProductStateViewModel.State
    ) -> some View {
        
        HStack(spacing: 12) {
            
            // FIXME: create extension for data to image
            Image(data: productViewModel.main.cardLogo.data)
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)
            
            VStack(alignment: .leading, spacing: 0) {
                
                ProductView.HeaderView(
                    viewModel: productViewModel.header,
                    appearance: appearance
                )
                
                Spacer()
                
                mainView(
                    productViewModel,
                    state: state
                )
            }
        }
        .padding(.init(top: 13, leading: 12, bottom: 13, trailing: 16))
        .onTapGesture(perform: viewModel.chevronTapped)
    }
    
    private func mainView(
        _ viewModel: ProductViewModel,
        state: ProductStateViewModel.State
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 8) {

                // FIXME: create extension for data to image AGAIN
//                if let paymentSystemImage = viewModel.main.paymentSystem {
//                    
//                    Image(data: paymentSystemImage.data)
//                        .resizable()
//                        .frame(width: 24, height: 24, alignment: .center)
//                }
                
                Text(viewModel.main.name)
                    .lineLimit(1)
                    .font(appearance.textFont)
                    .foregroundColor(appearance.textColor)

                Spacer()
                
                Text(viewModel.main.balance)
                    .font(appearance.textFont)
                    .foregroundColor(appearance.textColor)
                
                if case .selected = state {
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24, alignment: .center)
                    
                } else {
                    
                    Image(systemName: "chevron.up")
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24, alignment: .center)
                }

            }
            
            ProductView.FooterView(
                viewModel: viewModel.footer,
                appearance: appearance
            )
        }
    }
    
    @ViewBuilder
    private func background(
        _ product: ProductViewModel
    ) -> some View {
        
        if let backgroundUIImage = product.main.backgroundImage {
            
            // FIXME: create extension for data to image AGAIN
            Image(data: backgroundUIImage.data)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        } else {
            
            product.main.backgroundColor
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
                .font(appearance.headerTextFont)
                .foregroundColor(appearance.headerTextColor)
        }
    }
    
    struct FooterView: View {
        
        let viewModel: ProductViewModel.FooterViewModel
        let appearance: Appearance
        
        var body: some View {
            
            Text(viewModel.description)
                .font(appearance.headerTextFont)
                .foregroundColor(appearance.headerTextColor)
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
    
    public struct Appearance {
        
        let headerTextColor: Color
        let headerTextFont: Font
        let textColor: Color
        let textFont: Font
        let optionConfig: OptionConfig
        let background: Background
        
        public init(
            headerTextColor: Color,
            headerTextFont: Font,
            textColor: Color,
            textFont: Font,
            optionConfig: OptionConfig,
            background: Background
        ) {
            self.headerTextColor = headerTextColor
            self.headerTextFont = headerTextFont
            self.textColor = textColor
            self.textFont = textFont
            self.optionConfig = optionConfig
            self.background = background
        }
        
        public struct OptionConfig {
            
            let numberColor: Color
            let numberFont: Font
            let nameColor: Color
            let nameFont: Font
            let balanceColor: Color
            let balanceFont: Font
            
            public init(
                numberColor: Color,
                numberFont: Font,
                nameColor: Color,
                nameFont: Font,
                balanceColor: Color,
                balanceFont: Font
            ) {
                self.numberColor = numberColor
                self.numberFont = numberFont
                self.nameColor = nameColor
                self.nameFont = nameFont
                self.balanceColor = balanceColor
                self.balanceFont = balanceFont
            }
        }
        
        public struct Background {
            
            let color: Color
            let image: Image?
            
            public init(
                color: Color,
                image: Image? = nil
            ) {
                self.color = color
                self.image = image
            }

        }
    }
}

extension ProductView.Appearance {
    
    static let `default`: Self = .init(
        headerTextColor: .accentColor,
        headerTextFont: .body,
        textColor: .accentColor,
        textFont: .body,
        optionConfig: .init(
            numberColor: .black,
            numberFont: .body,
            nameColor: .black,
            nameFont: .body,
            balanceColor: .black,
            balanceFont: .body
        ),
        background: .init(color: .yellow, image: nil)
    )
}

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ProductView(
            appearance: .default,
            viewModel: .init(
                state: .selected(.init(
                    id: 1,
                    header: .init(title: "Счет списания"),
                    main: .init(
                        cardLogo: .data(.empty),
                        paymentSystem: nil,
                        name: "Gold",
                        balance: "625 193 Р",
                        backgroundImage: .data(.empty),
                        backgroundColor: .red,
                        clover: .data(.empty)
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
