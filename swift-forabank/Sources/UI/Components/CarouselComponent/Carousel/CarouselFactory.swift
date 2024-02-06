//
//  CarouselFactory.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI
import RxViewModel

public typealias CarouselViewModel = RxViewModel<CarouselState, CarouselEvent, CarouselEffect>

final public class CarouselFactory {
    
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.scheduler = scheduler
    }
}

public extension CarouselFactory {
    
    func makeViewModel() -> CarouselViewModel {
        
        let reducer = CarouselReducer()
        let effectHandler = CarouselEffectHandler()
        
        return CarouselViewModel(
            initialState: .initial(.init()),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
