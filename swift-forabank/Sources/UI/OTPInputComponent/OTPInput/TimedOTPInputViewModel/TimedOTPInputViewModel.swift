//
//  TimedOTPInputViewModel.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Combine
import Foundation
import RxViewModel

public typealias OTPInputViewModel = RxViewModel<OTPInputState, OTPInputEvent, OTPInputEffect>

public final class TimedOTPInputViewModel: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let viewModel: OTPInputViewModel
    private var cancellable: AnyCancellable?
    
    public init(
        viewModel: OTPInputViewModel,
        timer: TimerProtocol = RealTimer(),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = viewModel.state
        self.viewModel = viewModel
        
        cancellable = viewModel.$state
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self, viewModel, timer] state in
                
                self?.state = state
                
                switch state {
                case .failure, .validOTP:
                    timer.stop()
                    
                case let .input(input):
                    switch input.countdown {
                    case .failure, .completed:
                        timer.stop()
                        
                    case .starting:
                        timer.start(
                            every: 1,
                            onRun: { viewModel.event(.countdown(.tick)) }
                        )
                        
                    case .running:
                        break
                    }
                }
            }
    }
}

public extension TimedOTPInputViewModel {
    
    func event(_ event: Event) {
        
        viewModel.event(event)
    }
}

public extension TimedOTPInputViewModel {
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
}
