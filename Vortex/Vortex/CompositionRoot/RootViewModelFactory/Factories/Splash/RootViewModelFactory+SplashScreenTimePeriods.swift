//
//  RootViewModelFactory+SplashScreenTimePeriods.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.03.2025.
//

import Foundation
import SplashScreenCore
import VortexTools

extension RootViewModelFactory {
    
    @inlinable
    func scheduleGetAndCacheSplashScreenTimePeriods() {
        
        schedulers.background.schedule { [weak self] in
            
            self?.getAndCacheSplashScreenTimePeriods { [weak self] wasUpdated in
                
                if wasUpdated { self?.clearSplashImagesCache() }
            }
        }
    }
    
    /// - Warning: This method is not responsible for threading.
    /// - Warning: This method has side-effect of clearing splash images cache on new time periods.
    @inlinable
    func getAndCacheSplashScreenTimePeriods(
        completion: @escaping (Bool) -> Void
    ) {
        let (loadTimePeriods, reloadTimePeriods) = makeNoFallbackSplashScreenTimePeriodsLoaders()
        
        loadTimePeriods { localTimePeriods in
            
            reloadTimePeriods { remoteTimePeriods in
                
                completion(localTimePeriods != remoteTimePeriods)
                
                _ = loadTimePeriods
                _ = reloadTimePeriods
            }
        }
    }
    
    /// Loads cached splash screen time periods with fallback to hardcoded default.
    /// - Warning: This method is not responsible for threading.
    @inlinable
    func loadSplashScreenTimePeriodsCache(
        completion: @escaping ([SplashScreenTimePeriods]) -> Void
    ) {
        let (loadTimePeriods, _) = makeNoFallbackSplashScreenTimePeriodsLoaders()
        
        loadTimePeriods { completion($0 ?? .default); _ = loadTimePeriods }
    }
}

// MARK: - Helpers

private extension Calendar {
    
    func timePeriod(
        for periods: [SplashScreenTimePeriod]?,
        with currentDate: @escaping () -> Date = Date.init
    ) -> String {
        
        let timeString = currentTimeString(currentDate: currentDate)
        let period = (periods ?? .default).period(for: timeString ?? "")
        
        return period?.timePeriod ?? "DAY"
    }
}

// MARK: - Defaults

extension Array where Element == SplashScreenTimePeriod {
    
    static let `default`: Self = [
        .init(timePeriod: "MORNING", startTime: "04:00", endTime: "11:59"),
        .init(timePeriod: "DAY",     startTime: "12:00", endTime: "17:59"),
        .init(timePeriod: "EVENING", startTime: "18:00", endTime: "23:59"),
        .init(timePeriod: "NIGHT",   startTime: "00:00", endTime: "03:59"),
    ]
}
