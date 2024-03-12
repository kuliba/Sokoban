//
//  ProductDetailsView.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

struct ProductDetailsView: View {
    
    let accountDetails: [ListItem]
    let cardDetails: [ListItem]
    let event: (ProductDetailEvent) -> Void
    let config: Config
    
    @Binding var isCheck: Bool
    @Binding var showCheckbox: Bool
    // TODO: paddings & etc -> Config
    var body: some View {
     
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                
                if !accountDetails.isEmpty {
                    
                    itemsView(
                        title: "Реквизиты счета",
                        items: accountDetails
                    )
                } else {
                    
                    noAccountDetails()
                }
                
                itemsView(
                    title: "Реквизиты карты",
                    items: cardDetails
                )
                // TODO: add action
                Button(action: {  }) {
                    
                    ZStack {
                        
                        Rectangle()
                            .fill(config.colors.fill)
                            .cornerRadius(12)
                        
                        Text("Поделиться")
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func noAccountDetails() -> some View {
        
        ZStack {
            
            Rectangle()
                .fill(config.colors.fill)
                .cornerRadius(90)
            
            HStack {
                
                Image(systemName: "ellipsis.bubble")
                
                Text("Реквизиты счета доступны владельцу основной карты. Он сможет их посмотреть в ЛК.")
                    .lineLimit(3)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
        .padding(.horizontal, 16)
    }
    
    private func itemsView(
        title: String,
        items: [ListItem]
    ) -> some View {
        
        ZStack {
            
            Rectangle()
                .fill(config.colors.fill)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 13) {
                
                titleWithCheckBox(title)
                divider()
                ForEach(items, id: \.self) { itemView(value: $0) }
            }
            .padding(.bottom, 13)
            .padding(.horizontal, 16)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func itemView(value: ListItem) -> some View {
        
        switch value {
            
        case let .single(item):
            
            ProductDetailView(item: item, event: event, config: config)
            divider()
            
        case let .multiple(items):
            
            HStack(spacing: 0) {
                
                ForEach(items, id: \.id) {
                    let isFirst = $0 == items.first
                    ProductDetailView(item: $0, event: event, config: config)
                        .padding(.leading, (isFirst ? 0 : 16))
                    if isFirst {
                        divider()
                            .rotationEffect(.degrees(90))
                            .frame(width: 32)
                    }
                }
            }
        }
    }
    
    private func titleWithCheckBox(_ title: String) -> some View {
        
        HStack {
            
            config.images.checkImage(isCheck)
                .frame(
                    width: showCheckbox ? config.iconSize : 0,
                    height: showCheckbox ? config.iconSize : 0,
                    alignment: .center)
                .onTapGesture { isCheck.toggle() }
                .opacity(showCheckbox ? 1 : 0)
            Text(title)
                .font(config.fonts.checkBoxTitle)
                .foregroundColor(config.colors.checkBoxTitle)
        }
        .padding(.top, 13)
    }
    
    private func divider() -> some View {
        
        Rectangle()
            .foregroundColor(.clear)
            .frame(height: 0.5)
            .frame(maxWidth: .infinity)
            .background(config.colors.divider)
    }
}

private extension Config.Images {
    
    func checkImage(_ check: Bool) -> Image {
        
        check ? checkOn : checkOff
    }
}

struct ProductDetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @State var trueValue = true
        @State var falseValue = false
        
        Group {
            ProductDetailsView(
                accountDetails: .accountItems,
                cardDetails: .cardItems,
                event: { print($0) },
                config: .preview,
                isCheck: $falseValue, 
                showCheckbox: $falseValue
            )
            ProductDetailsView(
                accountDetails: [],
                cardDetails: .cardItems,
                event: { print($0) },
                config: .preview,
                isCheck: $falseValue,
                showCheckbox: $trueValue
            )
            ProductDetailsView(
                accountDetails: .accountItems,
                cardDetails: .cardItems,
                event: { print($0) },
                config: .preview,
                isCheck: $trueValue,
                showCheckbox: $trueValue
            )
        }
    }
}

