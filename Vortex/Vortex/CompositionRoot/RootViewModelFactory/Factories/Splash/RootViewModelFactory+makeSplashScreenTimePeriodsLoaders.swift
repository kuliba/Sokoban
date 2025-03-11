//
//  RootViewModelFactory+makeSplashScreenTimePeriodsLoaders.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.03.2025.
//

import Foundation
import RemoteServices
import SerialComponents
import SplashScreenBackend
import SplashScreenCore
import VortexTools
import SwiftUI

extension RootViewModelFactory {
    
    // MARK: - Periods
    
    typealias SplashScreenTimePeriods = SplashScreenCore.SplashScreenTimePeriod
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
    
    @inlinable
    func makeNoFallbackSplashScreenTimePeriodsLoaders(
    ) -> (load: Load<[SplashScreenTimePeriods]?>, reload: Load<[SplashScreenTimePeriods]?>) {
        
        return composeLoadersWithoutFallback(
            remoteLoad: getSplashScreenTimePeriods,
            fromModel: { .init(codable: $0) },
            toModel: { $0.codable }
        )
    }
    
    // MARK: - Settings
    
    @inlinable
    func splashScreenSettingsRemoteLoad(
        period: String,
        serial: String?,
        completion: @escaping LoadCompletion<Result<SerialComponents.SerialStamped<String, [LinkSplashScreenSettings]>, Error>>
    ) {
        let remoteLoad =  nanoServiceComposer.composeSerialResultLoad(
            createRequest: { serial in
                
                try RequestFactory.createGetSplashScreenSettingsRequest(
                    serial: serial,
                    period: period
                )
            },
            mapResponse: { ResponseMapper.map(period, $0, $1) }
        )
        
        remoteLoad(serial) { completion($0); _ = remoteLoad }
    }
}

private extension ResponseMapper {
    
    static func map(
        _ period: String,
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> Result<SerialComponents.SerialStamped<String, [LinkSplashScreenSettings]>, any Error> {
        
        return RemoteServices.ResponseMapper
            .mapGetSplashScreenSettingsResponse(data, httpURLResponse)
            .map {
                
                return .init(
                    value: $0.list.compactMap {
                        $0.settings(period: period)
                    },
                    serial: $0.serial)
            }
            .mapError { $0 }
    }
}

// MARK: - Codable (Caching)

private extension RemoteServices.ResponseMapper.SplashScreenSettings {
    
    func settings(
        period: String
    ) -> LinkSplashScreenSettings? {
        
        return link.map { .init(link: $0, period: period) }
    }
}

private extension LinkSplashScreenSettings {
    
    var codable: CodableSplashScreenSettings {
        
        return .init(link: link, period: category)
    }
    
    init(codable: CodableSplashScreenSettings) {
        
        self.init(
            link: codable.link,
            period: codable.period
        )
    }
}

struct CodableSplashScreenSettings: Codable {
    
    let link: String
    let period: String
}

// MARK: - Codable (Caching)

private extension RemoteServices.ResponseMapper.SplashScreenTimePeriod {
    
    var period: SplashScreenCore.SplashScreenTimePeriod {
        
        return .init(timePeriod: timePeriod, startTime: startTime, endTime: endTime)
    }
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

struct CodableSplashScreenTimePeriod: Codable {
    
    let timePeriod: String
    let startTime: String
    let endTime: String
}
