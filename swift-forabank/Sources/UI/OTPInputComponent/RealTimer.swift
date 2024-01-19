//
//  RealTimer.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

import Combine
import Foundation

public class RealTimer: TimerProtocol {
    
    private var cancellable: AnyCancellable?
    
    public init() {}
    
    public func start(
        every interval: TimeInterval,
        onRun: @escaping () -> Void
    ) {
        cancellable = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in onRun() })
    }
    
    public func stop() {
        
        cancellable?.cancel()
        cancellable = nil
    }
}
