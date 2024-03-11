//
//  DetailsView.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

struct DetailsView: View {
    
    let items: [ListItem]
    let event: (DetailEvent) -> Void
    let config: Config
    let title: String
    let showCheckbox: Bool
    
    @Binding var isCheck: Bool
    // TODO: paddings & etc -> Config
    var body: some View {
        
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
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func itemView(value: ListItem) -> some View {
        
        switch value {
            
        case let .single(item):
            
            DetailView(item: item, event: event, config: config)
            divider()
            
        case let .multiple(items):
            
            HStack(spacing: 0) {
                
                ForEach(items, id: \.id) {
                    let isFirst = $0 == items.first
                    DetailView(item: $0, event: event, config: config)
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

struct ItemsViewNew_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @State var trueValue = true
        @State var falseValue = false
        
        Group {
            DetailsView(
                items: .preview,
                event: { print($0) },
                config: .preview,
                title: "Реквизиты счета",
                showCheckbox: false,
                isCheck: $falseValue
            )
            DetailsView(
                items: .preview,
                event: { print($0) },
                config: .preview,
                title: "Реквизиты счета",
                showCheckbox: true,
                isCheck: $falseValue
            )
            DetailsView(
                items: .cardItems,
                event: { print($0) },
                config: .preview,
                title: "Реквизиты карты",
                showCheckbox: true,
                isCheck: $trueValue
            )
        }
    }
}

