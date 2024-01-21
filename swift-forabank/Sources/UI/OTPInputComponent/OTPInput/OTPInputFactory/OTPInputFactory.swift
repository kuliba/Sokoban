//
//  OTPInputFactory.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Foundation

import Combine

public final class OTPInputFactory {
    
    private let initiate: CountdownEffectHandler.Initiate
    private let submitOTP: OTPFieldEffectHandler.SubmitOTP
    private let timer: TimerProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        initiate: @escaping CountdownEffectHandler.Initiate,
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP,
        timer: TimerProtocol = RealTimer()
    ) {
        self.initiate = initiate
        self.submitOTP = submitOTP
        self.timer = timer
    }
}

public extension OTPInputFactory {
    
    func make(
        initialOTPInputState: OTPInputState,
        duration: Int = 60,
        otpLength: Int = 6,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputViewModel {
        
        let countdownReducer = CountdownReducer(duration: duration)
        let otpFieldReducer = OTPFieldReducer(length: otpLength)
        let otpInputReducer = OTPInputReducer(
            countdownReduce: countdownReducer.reduce(_:_:),
            otpFieldReduce: otpFieldReducer.reduce(_:_:)
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: initiate)
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: submitOTP)
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        let otpInputViewModel = OTPInputViewModel(
            initialState: initialOTPInputState,
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
        
        bind(otpInputViewModel)
        
        return otpInputViewModel
    }
    
    private func bind(_ viewModel: OTPInputViewModel) {
        
        viewModel.$state
            .sink { [weak self, viewModel] state in
                
                switch state {
                case .failure, .validOTP:
                    self?.timer.stop()
                    
                case let .input(input):
                    switch input.countdown {
                    case .failure, .completed:
                        self?.timer.stop()
                        
                    case .starting:
                        self?.timer.start(
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
