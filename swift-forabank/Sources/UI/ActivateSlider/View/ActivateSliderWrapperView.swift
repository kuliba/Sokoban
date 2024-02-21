//
//  ActivateSliderWrapperView.swift
//
//
//  Created by Andryusina Nataly on 21.02.2024.
//

import SwiftUI
import RxViewModel

public typealias ActivateSliderViewModel = RxViewModel<SliderStatus, ActivateSlider.Event, ActivateSlider.Effect>

struct ActivateSliderWrapperView: View {
    
    @ObservedObject var viewModel: ActivateSliderViewModel
    let config: SliderConfig
    
    var body: some View {
        
        ActivateSliderView(
            state: viewModel.state,
            event: { _ in viewModel.event(.swipe) }, // TODO: need fix
            config: config
        )
    }
}
