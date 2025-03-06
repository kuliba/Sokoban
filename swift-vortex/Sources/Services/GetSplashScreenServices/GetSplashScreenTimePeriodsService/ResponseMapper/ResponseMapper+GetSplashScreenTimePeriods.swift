//
//  ResponseMapper+GetSplashScreenTimePeriodsResponse.swift
//
//
//  Created by Nikolay Pochekuev on 18.02.2025.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public typealias GetSplashScreenTimePeriodsResponse = SerialStamped<String, SplashScreenTimePeriod>
}

extension ResponseMapper {
    
    public struct SplashScreenTimePeriod: Equatable {
        
        public let timePeriod: String
        public let startTime: String
        public let endTime: String
        
        public init(
            timePeriod: String,
            startTime: String,
            endTime: String
        ) {
            self.timePeriod = timePeriod
            self.startTime = startTime
            self.endTime = endTime
        }
    }
}

public extension Array
where Element == RemoteServices.ResponseMapper.SplashScreenTimePeriod {
    
    func period(for string: String) -> String {
        
        let ranges = self.map { $0.startTime...$0.endTime }
        
        guard let index = ranges.firstIndex(where: { $0.contains(string) })
        else { return "DAY" }
        
        return self[index].timePeriod
    }
}

