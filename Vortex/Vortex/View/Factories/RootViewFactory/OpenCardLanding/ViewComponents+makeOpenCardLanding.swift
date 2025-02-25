//
//  ViewComponents+makeOpenCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 24.02.2025.
//

import DropDownTextListComponent
import ListLandingComponent
import HeaderLandingComponent
import SwiftUI
import UIPrimitives
import SavingsAccount

struct OrderCardLanding {
    
    let header: HeaderViewModel
    let conditions: ListLandingComponent.Items
    let security: ListLandingComponent.Items
    let dropDownList: DropDownListViewModel
}

extension ViewComponents {
    
    func makeOrderCardLandingView(
        landing: OrderCardLanding,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        DismissibleScrollView(
            title: { $0 > 0 ? "title" : "" },
            dismiss: dismiss
        ) {
            HeaderView(model: landing.header)
            
            ListLandingComponent.List(
                items: landing.conditions,
                config: .iVortex,
                factory: .init(
                    makeIconView: makeIconView,
                    makeBannerImageView: makeGeneralIconView
                )
            )
            
            ListLandingComponent.List(
                items: landing.security,
                config: .iVortex,
                factory: .init(
                    makeIconView: makeIconView,
                    makeBannerImageView: makeGeneralIconView
                )
            )
            
            DropDownList(viewModel: landing.dropDownList)
        }
    }
}

//TODO: add swipe to refresh
struct DismissibleScrollView<Content: View>: View {
    
    @State private var offset: CGPoint = .zero
    
    let title: (Double) -> String
    let dismiss: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        
        OffsetObservingScrollView(
            axes: .vertical,
            showsIndicators: false,
            offset: $offset,
            coordinateSpaceName: "orderCardScroll",
            content: content
        )
        .navigationBarWithBack(
            title: title(offset.y),
            dismiss: dismiss
        )
    }
}
