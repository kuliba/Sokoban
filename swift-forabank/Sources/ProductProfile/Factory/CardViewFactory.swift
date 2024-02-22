//
//  CardViewFactory.swift
//  
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import ActivateSlider
import RxViewModel

public struct CardViewFactory {
    
    public let activateSliderViewModel: CardViewModel
    
    public init(activateSliderViewModel: CardViewModel) {
        self.activateSliderViewModel = activateSliderViewModel
    }
}

public extension CardViewFactory {

    typealias MakeCardViewModel = (AnySchedulerOfDispatchQueue) -> CardViewModel
}
