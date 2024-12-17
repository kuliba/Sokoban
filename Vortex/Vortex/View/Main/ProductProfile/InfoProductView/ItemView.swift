//
//  ItemView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 22.06.2023.
//

import SwiftUI

struct ItemView: View {
    
    let item: InfoProductViewModel.ItemViewModelWithAction
    
    var body: some View {
        
        HStack {
            
            TitleSubtitleView(item: item)
            
            if let image = item.icon {
                
                image
                    .renderingMode(.template)
                    .foregroundColor(.textPlaceholder)
                    .frame(width: 24, height: 24, alignment: .center)
                    .onTapGesture {
                        
                        item.actionForIcon()
                    }
                    .accessibilityIdentifier("InfoProductItemButton")
            }
        }
    }
}

struct TitleSubtitleView: View {
    
    let item: InfoProductViewModel.ItemViewModelWithAction
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(item.title)
                .font(.textBodyMR14180())
                .foregroundColor(Color.textPlaceholder)
                .maxWidthLeadingFrame()
            Text(item.subtitle)
                .font(.textH4R16240())
                .foregroundColor(Color.textSecondary)
                .maxWidthLeadingFrame()
        }
        .onLongPressGesture(minimumDuration: 1) {
            
            item.actionForLongPress(item.valueForCopy, item.titleForInformer)
        }
    }
}

extension View {
    
    func maxWidthLeadingFrame() -> some View {
        
        frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct ItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ItemView(item: .accountNumberItem)
    }
}

private extension InfoProductViewModel.ItemViewModelWithAction {
    
    static let accountNumberItem: Self = .init(
        id: .accountNumber,
        title: "title",
        titleForInformer: "titleForInformer",
        subtitle: "subtitle",
        valueForCopy: "valueForCopy",
        actionForLongPress: { _,_ in
            
            print("LongPress")
        },
        actionForIcon: {
            
            print("Tap")
        }
    )
}
