//
//  ComposedCategoryPickerSectionView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.11.2024.
//

import PayHub
import PayHubUI
import RxViewModel
import SwiftUI

struct ComposedCategoryPickerSectionView<ContentView, DestinationView, FullScreenCoverView>: View
where ContentView: View,
      DestinationView: View,
      FullScreenCoverView: View {
    
    let binder: Binder
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                CategoryPickerSectionFlowView(
                    state: $0,
                    event: $1,
                    factory: factory
                )
            }
        )
    }
}

extension ComposedCategoryPickerSectionView {
    
    typealias Binder = CategoryPickerSectionDomain.Binder
    typealias Factory = CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, FullScreenCoverView>
}
