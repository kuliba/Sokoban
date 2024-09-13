//
//  ComposedBannersView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import Banners
import SwiftUI

struct ComposedBannersView<ContentView>: View
where ContentView: View {
    
    let bannersBinder: BannersBinder
    let factory: Factory
    
    var body: some View {
        
        BannersFlowWrapperView(
            model: bannersBinder.flow,
            makeContentView: {
                
                BannersFlowView(
                    state: $0,
                    event: $1,
                    factory: factory
                )
            }
        )
    }
}

extension ComposedBannersView {
    
    typealias Factory = BannersFlowViewFactory<ContentView>
}
