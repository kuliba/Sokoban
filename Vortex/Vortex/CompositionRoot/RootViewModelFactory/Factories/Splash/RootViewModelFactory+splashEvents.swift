//
//  RootViewModelFactory+splashEvents.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.03.2025.
//

import Combine

extension RootViewModelFactory {
    
    @inlinable
    func splashEvents(
        splash: SplashScreenViewModel
    ) -> Set<AnyCancellable> {
        
        var cancellables = Set<AnyCancellable>()
        
        model.pinOrSensorAuthOK
            .sink { [weak splash] in splash?.event(.prepare) }
            .store(in: &cancellables)
        
        #warning("hardcoded delay interval")
        model.hideCoverStartSplash
            .handleEvents(
                receiveOutput: { [weak splash] _ in splash?.event(.start) }
            )
            .delay(for: .seconds(1), scheduler: schedulers.background)
            .sink { [weak splash] in splash?.event(.hide) }
            .store(in: &cancellables)
        
        return cancellables
    }
}
