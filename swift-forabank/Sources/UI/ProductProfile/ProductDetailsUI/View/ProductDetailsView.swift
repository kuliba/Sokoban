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
    var showCheckbox: Bool
    let detailsState: DetailsState
    
    @Binding var isCheckAccount: Bool
    @Binding var isCheckCard: Bool
    
    // TODO: paddings & etc -> Config
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                
                if !accountDetails.isEmpty {
                    
                    itemsView(
                        title: "Реквизиты счета",
                        items: accountDetails,
                        isAccount: true
                    )
                } else {
                    
                    noAccountDetails()
                }
                
                itemsView(
                    title: "Реквизиты карты",
                    items: cardDetails,
                    isAccount: false
                )
            }
        }
        
        Button(action: { event(.share) }) {
            
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
        .disabled(buttonDisabled())
    }
    
    private func buttonDisabled() -> Bool {
        
        if showCheckbox {
            
            return !(isCheckCard || isCheckAccount)
        } else { return false }
    }
    
    private func noAccountDetails() -> some View {
        
        ZStack {
            
            Rectangle()
                .fill(config.colors.fill)
                .cornerRadius(90)
            
            HStack {
               
                ZStack {
                    
                    Rectangle()
                        .fill(.white)
                        .cornerRadius(16)

                    Image(systemName: "ellipsis.bubble")
                }
                .frame(width: 32, height: 32)

                Text("Реквизиты счета доступны владельцу основной карты. Он сможет их посмотреть в ЛК.")
                    .lineLimit(3)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
        .padding(.horizontal, 16)
    }
    
    private func itemsView(
        title: String,
        items: [ListItem],
        isAccount: Bool
    ) -> some View {
        
        ZStack {
            
            Rectangle()
                .fill(config.colors.fill)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 13) {
                
                titleWithCheckBox(title, isAccount: isAccount)
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
            
            ProductDetailView(item: item, event: event, config: config, detailsState: detailsState)
            divider()
            
        case let .multiple(items):
            
            HStack(spacing: 0) {
                
                ForEach(items, id: \.id) {
                    let isFirst = $0 == items.first
                    ProductDetailView(item: $0, event: event, config: config, detailsState: detailsState)
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
    
    private func titleWithCheckBox(_ title: String, isAccount: Bool) -> some View {
        
        HStack {
            
            config.images.checkImage(isAccount ? isCheckAccount : isCheckCard)
                .frame(
                    width: showCheckbox ? config.iconSize : 0,
                    height: showCheckbox ? config.iconSize : 0,
                    alignment: .center)
                .onTapGesture {
                    if isAccount
                    {
                        isCheckAccount.toggle()
                        event(.selectAccountValue(isCheckAccount))
                    } else {
                        isCheckCard.toggle()
                        event(.selectCardValue(isCheckCard))
                    }
                }
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
                showCheckbox: false, 
                detailsState: .initial,
                isCheckAccount: $falseValue,
                isCheckCard: $falseValue
            )
            ProductDetailsView(
                accountDetails: [],
                cardDetails: .cardItems,
                event: { print($0) },
                config: .preview,
                showCheckbox: true,
                detailsState: .needShowNumber,
                isCheckAccount: $falseValue,
                isCheckCard: $trueValue
            )
            ProductDetailsView(
                accountDetails: .accountItems,
                cardDetails: .cardItems,
                event: { print($0) },
                config: .preview,
                showCheckbox: true,
                detailsState: .needShowCvv,
                isCheckAccount: $trueValue,
                isCheckCard: $falseValue
            )
        }
    }
}

