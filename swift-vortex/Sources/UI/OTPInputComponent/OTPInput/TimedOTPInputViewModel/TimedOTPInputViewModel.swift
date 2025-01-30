//
//  TimedOTPInputViewModel.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Combine
import Foundation
import VortexTools
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
    
    convenience init(
        otpText: String,
        timerDuration: Int,
        otpLength: Int,
        timer: any TimerProtocol = RealTimer(),
        resend: @escaping () -> Void,
        observe: @escaping Observe = { _ in },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let countdownReducer = CountdownReducer(duration: timerDuration)
        let decorated: OTPInputReducer.CountdownReduce = { state, event in
            
            if case (.completed, .start) = (state, event) {
                resend()
            }
            
            return countdownReducer.reduce(state, event)
        }
        
        let otpFieldReducer = OTPFieldReducer(length: otpLength)
        let decoratedOTPFieldReduce: OTPInputReducer.OTPFieldReduce = { state, event in
            
            switch event {
            case let .edit(text):
                let text = text.filter(\.isWholeNumber).prefix(otpLength)
                return otpFieldReducer.reduce(state, .edit(.init(text)))
                
            default:
                return otpFieldReducer.reduce(state, event)
            }
        }
        let otpInputReducer = OTPComponentInputReducer(
            countdownReduce: decorated,
            otpFieldReduce : decoratedOTPFieldReduce
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: { _ in })
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: { _,_ in })
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        self.init(
            initialState: .starting(
                phoneNumber: "",
                duration: timerDuration,
                text: otpText
            ),
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            timer: timer,
            observe: observe,
            scheduler: scheduler
        )
    }
}

public extension TimedOTPInputViewModel {
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Observe = (String) -> Void
}
