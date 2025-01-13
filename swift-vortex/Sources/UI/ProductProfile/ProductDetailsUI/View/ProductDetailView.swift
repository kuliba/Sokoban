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
    let detailsState: DetailsState
    
    var body: some View {
        
        HStack {
            
            titleSubtitleView()
            
            if let image = config.images.iconBy(item.id, detailsState: detailsState) {
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
            Text(item.subtitle(detailsState: detailsState))
                .font(config.fonts.subtitle)
                .foregroundColor(config.colors.subtitle)
                .maxWidthLeadingFrame()
        }
        .onLongPressGesture(minimumDuration: 1) {
            
            event(.longPress(.init(item.value.copyValue), .init(item.informerTitle)))
        }
    }
}

private extension View {
    
    func maxWidthLeadingFrame() -> some View {
        
        frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Config.Images {
    
    func iconBy(_ id: DocumentItem.ID, detailsState: DetailsState) -> Image? {
        
        switch detailsState {
        case .initial:
            switch id {
            case .info:
                return info
            case .number, .cvv:
                return maskedValue
            default:
                return nil
            }
        case .needShowNumber:
            switch id {
            case .number:
                return showValue
            case .cvv:
                return maskedValue
            case .info:
                return info
            default:
                return nil
            }
        case .needShowCvv:
            switch id {
            case .number:
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
}

struct ProductDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
      
        Group {
            
            ProductDetailView(
                item: .accountNumber,
                event: { print("event - \($0)") },
                config: .preview, 
                detailsState: .initial
            )
            
            ProductDetailView(
                item: .cvvMasked,
                event: { print("event - \($0)") },
                config: .preview,
                detailsState: .initial
            )
            
            ProductDetailView(
                item: .info,
                event: { print("event - \($0)") },
                config: .preview,
                detailsState: .initial
            )
        }
    }
}
