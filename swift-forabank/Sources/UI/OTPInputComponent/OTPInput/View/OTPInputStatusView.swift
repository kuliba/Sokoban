//
//  OTPInputStatusView.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

struct OTPInputStatusView<InputView: View>: View {
    
    let state: State
    let inputView: (Input) -> InputView
    
    var body: some View {
        
        switch state {
        case .failure:
            EmptyView()
            
        case let .input(input):
            inputView(input)
            
        case .validOTP:
            EmptyView()
        }
    }
}

extension OTPInputStatusView {
    
    typealias Input = OTPInputState.Status.Input
    
    typealias State = OTPInputState.Status
    typealias Event = OTPInputEvent
    typealias Config = TimedOTPInputViewConfig
}

struct OTPInputStatusView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        List {
            
            view(.failure(.connectivityError))
            view(.failure(.serverError("Error!")))
            view(.validOTP)
            view(.input(.completeOTP))
            view(.input(.incompleteOTP))
            view(.input(.timerFailure))
            view(.input(.timerRunning))
            view(.input(.timerStarting))
            view(.input(.timerCompleted))
        }
        .listStyle(.plain)
    }
    
    private static func view(
        _ state: OTPInputStatusView.State
    ) -> some View {
        
        OTPInputStatusView(state: state, inputView: { Text(String(describing: $0)) })
    }
}
