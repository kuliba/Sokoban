//
//  ItemView.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

struct ItemView: View {
    
    let item: Item
    let actions: ItemActions
    let config: Config
    
    var body: some View {
        
        HStack {
            
            titleSubtitleView()
            
            if let image = config.images.iconBy(item.id) {
                
                image
                    .renderingMode(.template)
                    .foregroundColor(config.colors.image)
                    .frame(width: config.sizes.icon, height: config.sizes.icon, alignment: .center)
                    .onTapGesture {
                        
                        actions.actionForIcon()
                    }
                    .accessibilityIdentifier("InfoProductItemButton")
            }
        }
    }
    
    private func titleSubtitleView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(item.title)
                .font(config.fonts.title)
                .foregroundColor(config.colors.title)
                .maxWidthLeadingFrame()
            Text(item.subtitle)
                .font(config.fonts.subtitle)
                .foregroundColor(config.colors.subtitle)
                .maxWidthLeadingFrame()
        }
        .onLongPressGesture(minimumDuration: 1) {
            
            actions.actionForLongPress(item.valueForCopy, item.titleForInformer)
        }
    }
}

extension View {
    
    func maxWidthLeadingFrame() -> some View {
        
        frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Config.Images {
    
    func iconBy(_ id: DocumentItem.ID) -> Image? {
        
        switch id {
        case .numberMasked:
            return numberMasked
        case .number:
            return number
        case .cvvMasked:
            return cvvMasked
        case .cvv:
            return cvv
        default:
            return nil
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    
    static var previews: some View {
      
        Group {
            
            ItemView(
                item: .accountNumberItem,
                actions: .actions,
                config: .preview)
            
            ItemView(
                item: .cvvItem,
                actions: .actions,
                config: .preview)
        }
    }
}

private extension Item {
    
    static let accountNumberItem: Self = .init(
        id: .accountNumber,
        title: "title",
        titleForInformer: "titleForInformer",
        subtitle: "subtitle",
        valueForCopy: "valueForCopy"
    )
    
    static let cvvItem: Self = .init(
        id: .cvv,
        title: "title",
        titleForInformer: "titleForInformer",
        subtitle: "subtitle",
        valueForCopy: "valueForCopy"
    )

}

private extension ItemActions {
    
    static let actions: Self = .init(
        actionForLongPress: { _,_ in
            
            print("LongPress")
        },
        actionForIcon: {
            
            print("Tap")
        }
    )
}
