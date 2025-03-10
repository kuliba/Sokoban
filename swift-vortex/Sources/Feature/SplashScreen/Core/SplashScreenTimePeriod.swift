//
//  SplashScreenTimePeriod.swift
//  
//
//  Created by Igor Malyarov on 08.03.2025.
//

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

public extension Array where Element == SplashScreenTimePeriod {
    
    @inlinable
    func period(for timeString: String) -> Element? {
        
        first { $0.isMatch(for: timeString) }
    }
}

extension SplashScreenTimePeriod {
    
    @usableFromInline
    func isMatch(for timeString: String) -> Bool {
        
        (startTime...endTime).contains(timeString)
    }
}
