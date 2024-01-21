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
        viewModel: OTPInputViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        viewModel.$state
            .map(\.countdown)
            .sink { state in
                
                switch state {
                case .failure, .completed:
                    timer.stop()
                    
                    #warning("suboptimal - extra detail (`duration`) is needed to define state - looks like it would be better to model this differently, like `started` and modify tick to use internal duration with is one tick smaller")
                case .running(remaining: duration):
                    timer.start(
                        every: 1,
                        onRun: { [viewModel] in viewModel.event(.countdown(.tick)) }
                    )
                    
                case .running:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
