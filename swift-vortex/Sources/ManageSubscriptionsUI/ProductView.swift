//
//  ProductView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.07.2023.
//

import SwiftUI

public struct ProductViewModel {
    
    let image: Image
    let title: String
    let paymentSystemIcon: Image?
    let name: String
    let balance: String
    let descriptions: [String]
    let isLocked: Bool
    
    public init(
        image: Image,
        title: String,
        paymentSystemIcon: Image? = nil,
        name: String,
        balance: String,
        descriptions: [String],
        isLocked: Bool
    ) {
        self.image = image
        self.title = title
        self.paymentSystemIcon = paymentSystemIcon
        self.name = name
        self.balance = balance
        self.descriptions = descriptions
        self.isLocked = isLocked
    }
}

public struct ProductViewConfig {
    
    let titleFont: Font
    let titleColor: Color
    let nameFont: Font
    let nameColor: Color
    let descriptionFont: Font
    
    public init(
        titleFont: Font,
        titleColor: Color,
        nameFont: Font,
        nameColor: Color,
        descriptionFont: Font
    ) {
        
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.nameFont = nameFont
        self.nameColor = nameColor
        self.descriptionFont = descriptionFont
    }
}

public struct ProductView: View {
    
    let viewModel: ProductViewModel
    let configurator: ProductViewConfig
    
    public init(
        viewModel: ProductViewModel,
        configurator: ProductViewConfig
    ) {
        self.viewModel = viewModel
        self.configurator = configurator
    }
    
    public var body: some View {
        
        ZStack(alignment: .center) {
            
            HStack(alignment: .center ,spacing: 16) {
                
                ZStack {
                    
                    viewModel.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    
                    if viewModel.isLocked {
                        
                        Image(systemName: "lock")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 32, height: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    header(
                        font: configurator.titleFont,
                        foreground: configurator.titleColor
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                     
                        middleRow(
                            foregroundColor: configurator.nameColor,
                            font: configurator.nameFont
                        )
                        
                        description(
                            font: configurator.descriptionFont,
                            foreground: configurator.titleColor
                        )
                    }
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
        }
        .frame(height: 90)
        .padding(.horizontal, 12)
        .background(Color.clear)
    }
    
    private func header(font: Font, foreground: Color) -> some View {
        
        Text(viewModel.title)
            .font(font)
            .foregroundColor(foreground)
        
    }
    
    private func middleRow(foregroundColor: Color, font: Font) -> some View {
        
        HStack {
            
            if let paymentSystemIcon = viewModel.paymentSystemIcon {
                
                paymentSystemIcon
                    .renderingMode(.original)
            }
            
            Text(viewModel.name)
                .font(font)
                .foregroundColor(foregroundColor)
                .lineLimit(1)
            
            Spacer()
            
            Text(viewModel.balance)
                .font(font)
                .foregroundColor(foregroundColor)
            
        }
    }
    
    private func description(font: Font, foreground: Color) -> some View {
        
        HStack(spacing: 8) {
            
            ForEach(viewModel.descriptions, id: \.self) { description in
                
                Circle()
                    .frame(width: 3)
                
                Text(description)
                    .font(font)
            }
            .foregroundColor(foreground)
        }
        .padding(.bottom, 12)
    }
}

struct ProductView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ProductView(viewModel: .init(
            image: .init("creditcard"),
            title: "Title",
            paymentSystemIcon: .init("personalhotspot"),
            name: "Name",
            balance: "Balance",
            descriptions: ["Description"],
            isLocked: false),
            configurator: .init(
                titleFont: .body,
                titleColor: .red,
                nameFont: .body,
                nameColor: .blue,
                descriptionFont: .caption2
            )
        )
    }
}
