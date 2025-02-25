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
        landing: OrderCardLanding
    ) -> some View {
        
        OffsetObservingScrollView(
            axes: .vertical,
            showsIndicators: false,
            offset: .init(
                get: { .zero },
                set: { _ in  }
            ),
            coordinateSpaceName: "orderCardScroll") {
                
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
