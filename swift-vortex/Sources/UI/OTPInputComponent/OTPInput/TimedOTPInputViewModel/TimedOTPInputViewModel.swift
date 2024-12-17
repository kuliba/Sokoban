//
//  TimedOTPInputViewModel.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Combine
import Foundation
import ForaTools
import RxViewModel

public typealias OTPInputViewModel = RxViewModel<OTPInputState, OTPInputEvent, OTPInputEffect>

public final class TimedOTPInputViewModel: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let viewModel: OTPInputViewModel
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        viewModel: OTPInputViewModel,
        timer: TimerProtocol = RealTimer(),
        observe: @escaping Observe = { _ in },
        codeObserver: AnyPublisher<String, Never>,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = viewModel.state
        self.viewModel = viewModel
        
        let statePublisher = viewModel.$state.share()
        
        statePublisher
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self, viewModel, timer] state in
                
                self?.state = state
                
                switch state.status {
                case .validOTP:
                    timer.stop()
                case let .failure(input, failure):
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
        
        statePublisher
            .compactMap {
                
                guard case let .input(input) = $0.status else { return nil }
                
                return input.otpField.text
            }
            .removeDuplicates()
            .sink(receiveValue: observe)
            .store(in: &cancellables)
        
        codeObserver
            .receive(on: scheduler)
            .sink { [weak self] code in
            
                self?.event(.otpField(.edit(code)))
            }
            .store(in: &cancellables)
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
    typealias Observe = (String) -> Void
}
