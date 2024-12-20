//
//  RootViewModelFactory+runOnEachNextActiveSession.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.12.2024.
//

import Combine

extension RootViewModelFactory {
    
    func runOnEachNextActiveSession(
        _ work: @escaping () -> Void
    ) -> AnyCancellable {
        
        model.sessionAgent.sessionState
            .compactMap(\.token)
            .dropFirst()
            .map { _ in () }
            .sink(receiveValue: work)
    }
}
