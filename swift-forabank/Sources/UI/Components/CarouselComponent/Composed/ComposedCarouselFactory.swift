//
//  ComposedCarouselFactory.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI
import RxViewModel

public typealias ComposedCarouselViewModel = RxViewModel<ComposedCarouselState, ComposedCarouselEvent, ComposedCarouselEffect>

final public class ComposedCarouselFactory {
    
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.scheduler = scheduler
    }
}

public extension ComposedCarouselFactory {
    
    func makeViewModel() -> ComposedCarouselViewModel {
        
        let reducer = ComposedCarouselReducer(
            carouselReducer: .init(),
            selectorReducer: .init()
        )
        let effectHandler = ComposedCarouselEffectHandler(
            carouselEffectHandler: .init(),
            selectorEffectHandler: .init()
        )
        
        return ComposedCarouselViewModel(
            initialState: .init(
                carouselCarouselState: .initial(.init()),
                selectorCarouselState: .initial(.init())
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

