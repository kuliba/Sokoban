//
//  ProductDetailView.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

struct ProductDetailView: View {
    
    let item: ProductDetail
    let event: (ProductDetailEvent) -> Void
    let config: Config
    
    var body: some View {
        
        HStack {
            
            titleSubtitleView()
            
            if let image = config.images.iconBy(item.id) {
                image
                    .renderingMode(.template)
                    .foregroundColor(config.colors.image)
                    .frame(width: config.iconSize, height: config.iconSize, alignment: .center)
                    .onTapGesture {
                        event(.iconTap(item.id))
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
            
            event(.longPress(.init(item.copyValue), .init(item.informerTitle)))
        }
    }
}

private extension View {
    
    func maxWidthLeadingFrame() -> some View {
        
        frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Config.Images {
    
    func iconBy(_ id: DocumentItem.ID) -> Image? {
        
        switch id {
        case .numberMasked:
            return maskedValue
        case .number:
            return showValue
        case .cvvMasked:
            return maskedValue
        case .cvv:
            return showValue
        case .info:
            return info
        default:
            return nil
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
      
        Group {
            
            ProductDetailView(
                item: .accountNumber,
                event: { print("event - \($0)") },
                config: .preview)
            
            ProductDetailView(
                item: .cvvMasked,
                event: { print("event - \($0)") },
                config: .preview)
            
            ProductDetailView(
                item: .info,
                event: { print("event - \($0)") },
                config: .preview)
        }
    }
}
