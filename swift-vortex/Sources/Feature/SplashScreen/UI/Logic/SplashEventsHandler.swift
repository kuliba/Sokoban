//
//  SplashEventsHandler.swift
//
//
//  Created by Igor Malyarov on 15.03.2025.
//

import Combine
import CombineSchedulers
import Foundation

public final class SplashEventsHandler {
    
    private let authOKPublisher: VoidPublisher
    private let startPublisher: VoidPublisher
    private let event: (SplashScreenEvent) -> Void
    
    public init(
        authOKPublisher: VoidPublisher,
        startPublisher: VoidPublisher,
        event: @escaping (SplashScreenEvent) -> Void
    ) {
        self.authOKPublisher = authOKPublisher
        self.startPublisher = startPublisher
        self.event = event
    }
    
    public typealias VoidPublisher = AnyPublisher<Void, Never>
}

public extension SplashEventsHandler {
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    func bind(
        delay: Delay = .seconds(1),
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) -> Set<AnyCancellable> {
        
        var cancellables = Set<AnyCancellable>()
        
        authOKPublisher
            .sink { [weak self] in  self?.event(.prepare) }
            .store(in: &cancellables)
        
        startPublisher
            .handleEvents(receiveOutput: { [weak self] in self?.event(.start) })
            .delay(for: delay, scheduler: scheduler)
            .sink { [weak self] in self?.event(.hide) }
            .store(in: &cancellables)
        
        return cancellables
    }
}
