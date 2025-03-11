//
//  RootViewModelFactory+getSplashScreenTimePeriods.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.03.2025.
//

import Foundation
import RemoteServices
import SplashScreenBackend

#warning("taken from WIPTest")
extension Calendar {
    
    /// Returns the current time formatted as a string (`HH:mm`).
    ///
    /// - Parameters:
    ///   - currentDate: Closure returning the current `Date`. Defaults to `Date.init`.
    ///   - separator: Separator between hour and minute. Defaults to ":".
    /// - Returns: Formatted time string (`HH:mm`), or `nil` if extraction fails.
    func currentTimeString(
        currentDate: @escaping () -> Date = Date.init,
        separator: String = ":"
    ) -> String? {
        
        let components = dateComponents([.hour, .minute], from: currentDate())
        
        guard
            let hour = components.hour,
            let minute = components.minute
        else { return nil }
        
        return String(format: "%02d%@%02d", hour, separator, minute)
    }
}

