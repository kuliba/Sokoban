//
//  CarouselFactory.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI
import RxViewModel

final public class CarouselFactory {
    
    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.scheduler = scheduler
    }
}

public extension CarouselFactory {
    
    func makeViewModel(
        initialState: CarouselState,
        reducer: CarouselReducer = CarouselReducer(),
        effectHandler: CarouselEffectHandler = CarouselEffectHandler()
    ) -> CarouselViewModel {
        
        CarouselViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
