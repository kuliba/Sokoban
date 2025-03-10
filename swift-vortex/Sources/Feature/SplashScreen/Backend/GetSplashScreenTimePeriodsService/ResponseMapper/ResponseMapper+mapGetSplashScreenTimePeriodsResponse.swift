//
//  ResponseMapper+mapGetSplashScreenTimePeriodsResponse.swift
//
//
//  Created by Nikolay Pochekuev on 18.02.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetSplashScreenTimePeriodsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetSplashScreenTimePeriodsResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetSplashScreenTimePeriodsResponse.init)
    }
}

private extension ResponseMapper.GetSplashScreenTimePeriodsResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        guard let timePeriods = data.splashScreenTimePeriods,
              let serial = data.serial
        else { throw ResponseFailure() }
        
        self.init(
            list: timePeriods.compactMap(ResponseMapper.SplashScreenTimePeriod.init),
            serial: serial
        )
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper.SplashScreenTimePeriod {
    
    init?(_ data: ResponseMapper._Data._TimePeriods) {
        
        guard let timePeriod = data.timePeriod,
              let startTime = data.startTime,
              let endTime = data.endTime
        else { return nil }
        
        self.init(timePeriod: timePeriod, startTime: startTime, endTime: endTime)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String?
        let splashScreenTimePeriods: [_TimePeriods]?
        
        struct _TimePeriods: Decodable {
            
            let timePeriod: String?
            let startTime: String?
            let endTime: String?
        }
    }
}
