//
//  RootViewModelFactory+makeSplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreenUI
import SwiftUI

extension RootViewModelFactory {
    
    @inlinable
    func makeSplashScreenViewModel(
        flag: SplashScreenFlag
    ) -> SplashScreenViewModel {
        
        let composed = composeSplashScreenSettings()
        
        let initialState = SplashScreenState(
            phase: flag.isActive ? .cover : .hidden,
            settings: composed
        )
        let reducer = SplashScreenReducer()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: { _,_ in },
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func composeSplashScreenSettings() -> SplashScreenState.Settings {
        
        let timePeriod = getTimePeriodString()
        let cache = loadSplashImagesCache()
        
        guard let items = cache?.items(for: timePeriod)?.settings
        else { return .default }
        
        return items.randomElement() ?? .default
    }
}

private extension SplashScreenState.Settings {
    
    static let `default`: Self = .init(image: .init("splash"))
}

// MARK: - Adapters

private extension Array where Element == SplashScreenSettings {
    
    var settings: [SplashScreenState.Settings] {
        
        compactMap {
            
            guard case let .success(data) = $0.imageData,
                  let image = Image(data: data)
            else { return nil }
            
            return .init(image: image)
        }
    }
}
