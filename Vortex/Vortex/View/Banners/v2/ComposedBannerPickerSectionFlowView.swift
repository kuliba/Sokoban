//
//  ComposedBannerPickerSectionFlowView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import Banners
import SwiftUI

struct ComposedBannerPickerSectionFlowView<BannerPickerItem, DestinationView>: View
where BannerPickerItem: View,
      DestinationView: View {
    
    let binder: BannerPickerSectionBinder
    let config: Config
    let itemView: (BannerPickerSectionState.Item) -> BannerPickerItem
    let makeDestinationView: MakeDestinationView

    var body: some View {
        
        BannerPickerSectionFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                BannerPickerSectionFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: makeContentView,
                        makeDestinationView: makeDestinationView
                    )
                )
            }
        )
    }
}

extension ComposedBannerPickerSectionFlowView {

    typealias MakeDestinationView = (BannerPickerSectionDestination) -> DestinationView
    typealias Config = BannerPickerSectionContentViewConfig
}

private extension ComposedBannerPickerSectionFlowView {
    
    func makeContentView() -> some View {
        
        BannerPickerSectionContentWrapperView(
            model: binder.content,
            makeContentView: { state, event in
                
                BannerPickerSectionContentView(
                    state: state,
                    event: event,
                    config: config,
                    itemView: itemView
                )
            }
        )
    }
}
