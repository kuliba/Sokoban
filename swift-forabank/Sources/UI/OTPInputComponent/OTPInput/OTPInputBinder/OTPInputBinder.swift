//
//  OTPInputBinder.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Combine
import RxViewModel

public typealias OTPInputViewModel = RxViewModel<OTPInputState, OTPInputEvent, OTPInputEffect>

public final class OTPInputBinder {
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        timer: TimerProtocol = RealTimer(),
        duration: Int,
        otpInputViewModel viewModel: OTPInputViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        viewModel.$state
            .sink { [viewModel] state in
                
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
            .store(in: &cancellables)
    }
}
