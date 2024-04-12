//
//  BottomSheetReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.04.2024.
//

import Foundation

final class BottomSheetReducer {
    
    private let bottomSheetLifespan: DispatchTimeInterval

    init(
        bottomSheetLifespan: DispatchTimeInterval = .microseconds(400)
    ) {
        self.bottomSheetLifespan = bottomSheetLifespan
    }
}

extension BottomSheetReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .delayBottomSheet(bottomSheet):
            effect = .delayBottomSheet(bottomSheet, bottomSheetLifespan)
            
        case let .showBottomSheet(bottomSheet):
            state = bottomSheet
        }
        return (state, effect)
    }
}

extension BottomSheetReducer {
    
    typealias Event = BottomSheetEvent
    typealias State = ProductProfileViewModel.BottomSheet?
    typealias Effect = ProductNavigationStateEffect
}
