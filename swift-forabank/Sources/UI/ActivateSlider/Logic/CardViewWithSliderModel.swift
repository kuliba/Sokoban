//
//  CardViewWithSliderModel.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Combine
import Foundation
import RxViewModel

public typealias CardViewModel = RxViewModel<CardState, CardEvent, CardEffect>

public final class CardViewWithSliderModel: ObservableObject {
    
    @Published public private(set) var state: State
    
    let sliderViewModel: SliderViewModel
    let viewModel: CardViewModel
    private var cancellable: AnyCancellable?
    
    public init(
        viewModel: CardViewModel,
        maxOffsetX: CGFloat,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = viewModel.state
        self.viewModel = viewModel
        self.sliderViewModel = .init(
            maxOffsetX: maxOffsetX,
            didSwitchOn: {
                viewModel.event(.activateCard)
            })
        
        cancellable = viewModel.$state
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self, sliderViewModel] state in
                self?.state = state
                
                if case .status(nil) = state {
                    sliderViewModel.reset()
                }
            }
    }
}

public extension CardViewWithSliderModel {
    
    func event(_ event: Event) {
        
        viewModel.event(event)
    }
}

public extension CardViewWithSliderModel {
    
    typealias State = CardState
    typealias Event = CardEvent
}
