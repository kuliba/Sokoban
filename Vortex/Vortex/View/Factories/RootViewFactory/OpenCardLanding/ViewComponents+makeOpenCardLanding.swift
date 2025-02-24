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
        imageFactory: ListImageViewFactory
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
                    factory: imageFactory
                )
                
                ListLandingComponent.List(
                    items: landing.security,
                    config: .iVortex,
                    factory: imageFactory
                )
                
                DropDownList(viewModel: landing.dropDownList)
            }
    }
}

extension ListLandingComponent.Config {
    
    static let iVortex: Self = .init(
        background: .mainColorsGrayLightest,
        item: .init(
            title: .init(
                textFont: .textH4M16240(),
                textColor: .secondary
            ),
            subtitle: .init(
                textFont: .textBodyMR14180(),
                textColor: .textPlaceholder
            )
        ),
        title: .init(
            textFont: .textH3Sb18240(),
            textColor: .mainColorsBlack
        ),
        spacing: 18
    )
}
