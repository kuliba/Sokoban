//
//  CountdownComposer.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Combine
import ForaTools
import Foundation

public final class CountdownComposer {
    
    private let activate: Activate
    private let timer: TimerProtocol
    private let scheduler: AnySchedulerOfDispatchQueue
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        activate: @escaping Activate,
        timer: TimerProtocol = RealTimer(),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.activate = activate
        self.timer = timer
        self.scheduler = scheduler
    }
}

public extension CountdownComposer {
    
    func makeViewModel(duration: Int = 60) -> CountdownViewModel {
        
        let reducer = CountdownReducer(duration: duration)
        let effectHandler = CountdownEffectHandler(initiate: activate)
        
        let viewModel = CountdownViewModel(
            initialState: .running(remaining: duration),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
        
        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .failure, .completed:
                    self?.timer.stop()
                    
                case .starting:
                    self?.timer.start(
                        every: 1,
                        onRun: { [weak viewModel] in viewModel?.event(.tick) }
                    )
                    
                case .running:
                    break
                }
            }
            .store(in: &cancellables)
        
        return viewModel
    }
}

public extension CountdownComposer {
    
    typealias ActivateResult = Result<Void, ServiceFailure>
    typealias ActivateCompletion = (ActivateResult) -> Void
    typealias Activate = (@escaping ActivateCompletion) -> Void
}
