//
//  ItemsViewNew.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 22.06.2023.
//

import SwiftUI

struct ItemsViewNew: View {
    
    let items: [InfoProductViewModel.ItemViewModelForList]
    let title: String
    let showCheckbox: Bool
    
    @Binding var isCheck: Bool
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .fill(Color.mainColorsGrayLightest)
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 13) {
                
                TitleWithCheckBox(
                    title: title,
                    showCheckbox: showCheckbox,
                    isCheck: $isCheck)
                
                CustomDivider()

                ForEach(items, id: \.self) { value in
                    
                    ItemViewNew(value: value)
                }
            }
            .padding(.bottom, 13)
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
    }
}

struct ItemViewNew: View {
    
    let value: InfoProductViewModel.ItemViewModelForList
    
    var body: some View {
        
        switch value {
            
        case let .single(item):
            
            ItemView(item: item)
            CustomDivider()
            
        case let .multiple(items):
            
            HStack(spacing: 0) {
                
                ForEach(items, id: \.id) { item in
                    
                    let isFirst = item == items.first
                    
                    ItemView(item: item)
                        .padding(.leading, (isFirst ? 0 : 16))
                    if isFirst {
                        
                        CustomDivider()
                            .rotationEffect(.degrees(90))
                            .frame(width: 32)
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
   
    let showCheckbox: Bool
    
    @Binding var isCheck: Bool

    var body: some View {
        
        HStack {
            
            if showCheckbox {
                
                Image(isCheck ? "Checkbox_active" : "Checkbox_normal")
                    .frame(width: showCheckbox ? 24 : 0, height: showCheckbox ? 24 : 0, alignment: .center)
                    .onTapGesture {
                        
                        isCheck.toggle()
                    }
            }
            Text(title)
                .font(.textH3Sb18240())
                .foregroundColor(.textSecondary)
        }
        .padding(.top, 13)
    }
}

struct ItemsViewNew_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @State var trueValue = true
        @State var falseValue = false
        
        NavigationView {
            
            ItemsViewNew(
                items: .items,
                title: "Реквизиты счета",
                showCheckbox: false,
                isCheck: $falseValue
            )
        }
        
        NavigationView {
            
            ItemsViewNew(
                items: .items,
                title: "Реквизиты счета",
                showCheckbox: true,
                isCheck: $trueValue
            )
        }
    }
}
