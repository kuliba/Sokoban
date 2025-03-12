//
//  ViewComponents+makeCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 12.03.2025.
//

import OrderCardLandingComponent
import RxViewModel
import SwiftUI
import UIPrimitives

extension ViewComponents {
    
    @inlinable
    func makeCardLandingView(
        binder: CardLandingDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        OffsetObservingScrollWithModelView(refresh: {
            binder.content.event(.load)
        }) { offset in
            
            RxWrapperView(model: binder.content) {state, event in
                
                switch state.status {
                case let .landing(landing):
                    let products = landing.map { $0 }
                    
                    makeCardLandingContentView(
                        products: products,
                        offset: offset
                    )
                default:
                    //TODO: add other cases
                    EmptyView()
                }
            }
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeCardLandingContentView(
        products: [Product],
        offset: Binding<CGPoint>
    ) -> some View {
        
        OffsetObservingScrollView(
            axes: .vertical,
            showsIndicators: false,
            offset: offset,
            coordinateSpaceName: "coordinateSpaceName"
        ) {
            VStack {
                
                ProductsLandingView(
                    products: products,
                    event: { _ in },
                    config: .iVortex,
                    viewFactory: .init(makeBannerImageView: makeGeneralIconView)
                )
            }
        }
    }
}
