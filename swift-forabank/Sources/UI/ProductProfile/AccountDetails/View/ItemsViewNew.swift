//
//  ItemsViewNew.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

struct ItemsViewNew: View {
    
    let items: [ItemForList]
    let event: (ItemEvent) -> Void
    let config: Config
    let title: String
    let showCheckbox: Bool
    
    @Binding var isCheck: Bool
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .fill(config.colors.fill)
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 13) {
                
                TitleWithCheckBox(
                    title: title,
                    config: config,
                    showCheckbox: showCheckbox,
                    isCheck: $isCheck)
                
                CustomDivider()
                
                ForEach(items, id: \.self) { value in
                    
                    ItemViewNew(value: value, event: event, config: config)
                }
            }
            .padding(.bottom, 13)
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
    }
}
struct ItemViewNew: View {
    
    let value: ItemForList
    let event: (ItemEvent) -> Void
    let config: Config
    
    var body: some View {
        
        switch value {
            
        case let .single(item):
            
            ItemView(item: item, event: event, config: config)
            CustomDivider()
            
        case let .multiple(items):
            
            HStack(spacing: 0) {
                
                ForEach(items, id: \.id) { item in
                    
                    let isFirst = item == items.first
                    
                    ItemView(item: item, event: event, config: config)
                        .padding(.leading, (isFirst ? 0 : 16))
                    
                    if isFirst {
                        
                        CustomDivider()
                            .rotationEffect(.degrees(90))
                            .frame(width: 16)
                    }
                }
            }
        }
    }
}

struct CustomDivider: View {
    
    let color: Color
    
    init(
        color: Color = Color(red: 0.83, green: 0.83, blue: 0.83).opacity(0.3)
    ) {
        self.color = color
    }
    
    var body: some View {
        
        Rectangle()
            .foregroundColor(.clear)
            .frame(height: 0.5)
            .frame(maxWidth: .infinity)
            .background(color)
    }
}

struct TitleWithCheckBox: View {
    
    let title: String
    let config: Config
    
    let showCheckbox: Bool
    
    @Binding var isCheck: Bool
    
    var body: some View {
        
        HStack {
            
            config.images.checkImage(isCheck)
                .frame(width: showCheckbox ? 24 : 0, height: showCheckbox ? 24 : 0, alignment: .center)
                .onTapGesture {
                    
                    isCheck.toggle()
                }
                .opacity(showCheckbox ? 1 : 0)
            
            Text(title)
                .font(config.fonts.checkBoxTitle)
                .foregroundColor(config.colors.checkBoxTitle)
        }
        .padding(.top, 13)
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
        
        NavigationView {
            
            ItemsViewNew(
                items: .preview,
                event: { print($0) },
                config: .preview,
                title: "Реквизиты счета",
                showCheckbox: false,
                isCheck: $falseValue
            )
        }
        
        NavigationView {
            
            ItemsViewNew(
                items: .preview,
                event: { print($0) },
                config: .preview,
                title: "Реквизиты счета",
                showCheckbox: true,
                isCheck: $falseValue
            )
        }
        
        NavigationView {
            
            ItemsViewNew(
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

