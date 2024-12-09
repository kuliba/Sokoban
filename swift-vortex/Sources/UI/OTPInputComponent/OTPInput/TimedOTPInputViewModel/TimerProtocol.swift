//
//  TimerProtocol.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation

public protocol TimerProtocol {
    
    func start(
        every interval: TimeInterval,
        onRun: @escaping () -> Void
    )
    func stop()
}
