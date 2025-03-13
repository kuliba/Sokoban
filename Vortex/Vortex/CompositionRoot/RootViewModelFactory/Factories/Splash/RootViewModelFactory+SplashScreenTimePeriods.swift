//
//  RootViewModelFactory+SplashScreenTimePeriods.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.03.2025.
//

import Foundation
import RemoteServices
import SerialComponents
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
    
    typealias SplashScreenTimePeriods = SplashScreenCore.SplashScreenTimePeriod
    
    @inlinable
    func makeNoFallbackSplashScreenTimePeriodsLoaders(
    ) -> (load: Load<[SplashScreenTimePeriods]?>, reload: Load<[SplashScreenTimePeriods]?>) {
        
        return composeLoadersWithoutFallback(
            remoteLoad: getSplashScreenTimePeriods,
            fromModel: { .init(codable: $0) },
            toModel: { $0.codable }
        )
    }
    
    typealias StampedSplashScreenPeriods = SerialComponents.SerialStamped<String, [SplashScreenTimePeriod]>
    
    /// Remote.
    @inlinable
    func getSplashScreenTimePeriods(
        serial: String?,
        completion: @escaping (Result<StampedSplashScreenPeriods, Error>) -> Void
    ) {
        let remoteLoad = nanoServiceComposer.composeSerialResultLoad(
            createRequest: RequestFactory.createGetSplashScreenTimePeriodsRequest,
            mapResponse: {
                
                RemoteServices.ResponseMapper
                    .mapGetSplashScreenTimePeriodsResponse($0, $1)
                    .map { .init(value: $0.list.map(\.period), serial: $0.serial) }
                    .mapError { $0 }
            }
        )
        
        remoteLoad(serial) { completion($0); _ = remoteLoad }
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

private extension Array where Element == SplashScreenTimePeriod {
    
    static let `default`: Self = [
        .init(timePeriod: "MORNING", startTime: "04:00", endTime: "11:59"),
        .init(timePeriod: "DAY",     startTime: "12:00", endTime: "17:59"),
        .init(timePeriod: "EVENING", startTime: "18:00", endTime: "23:59"),
        .init(timePeriod: "NIGHT",   startTime: "00:00", endTime: "03:59"),
    ]
}

// MARK: - Adapters

private extension RemoteServices.ResponseMapper.SplashScreenTimePeriod {
    
    var period: SplashScreenCore.SplashScreenTimePeriod {
        
        return .init(timePeriod: timePeriod, startTime: startTime, endTime: endTime)
    }
}

// MARK: - Codable (Caching)

private struct CodableSplashScreenTimePeriod: Codable {
    
    let timePeriod: String
    let startTime: String
    let endTime: String
}

private extension SplashScreenCore.SplashScreenTimePeriod {
    
    var codable: CodableSplashScreenTimePeriod {
        
        return .init(timePeriod: timePeriod, startTime: startTime, endTime: endTime)
    }
    
    init(codable: CodableSplashScreenTimePeriod) {
        
        self.init(
            timePeriod: codable.timePeriod,
            startTime: codable.startTime,
            endTime: codable.endTime
        )
    }
}
