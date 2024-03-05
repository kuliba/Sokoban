//
//  CarouselViewModel.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import RxViewModel

public typealias CarouselViewModel = RxViewModel<CarouselState, CarouselEvent, CarouselEffect>

public extension CarouselViewModel {
        
    convenience init(initialState: CarouselState) {
        
        let reducer = CarouselReducer()
        let effectHandler = CarouselEffectHandler()
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}
