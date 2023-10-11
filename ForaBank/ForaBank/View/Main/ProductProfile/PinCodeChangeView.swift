//
//  PinCodeChangeView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 13.07.2023.
//

import Combine
import SwiftUI
import PinCodeUI

struct PinCodeChangeView<ConfirmationView: View>: View {
    
    @ObservedObject private var viewModel: PinCodeViewModel
    
    private let config: PinCodeView.Config
    private let confirmationView: (PinCodeViewModel.PhoneNumber) -> ConfirmationView
    
    init(
        config: PinCodeView.Config,
        viewModel: PinCodeViewModel,
        confirmationView: @escaping (PinCodeViewModel.PhoneNumber) -> ConfirmationView
    ) {
        self.config = config
        self.viewModel = viewModel
        self.confirmationView = confirmationView
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            PinCodeView(
                viewModel: viewModel,
                config: config.pinCodeConfig)
            .padding(.bottom, 16)
            
            KeyPad(
                string: $viewModel.state.code,
                config: config.buttonConfig,
                deleteImage: .ic40Delete,
                pinCodeLength: viewModel.pincodeLength,
                action: viewModel.confirm
            )
            .fixedSize()
            .animationsDisabled()
            .fullScreenCover(
                item: .init(
                    get: { viewModel.phoneNumber },
                    set: viewModel.dismissFullCover
                ),
                onDismiss: { },
                content: { phoneNumber in
                    
                    NavigationView {
                        
                        confirmationView(.init(value: phoneNumber.value))
                    }
                }
            )
            
            Spacer()
        }
    }
}

private extension View {
    
    func animationsDisabled() -> some View {
        return self.transaction { (tx: inout Transaction) in
            tx.disablesAnimations = true
            tx.animation = nil
        }.animation(nil)
    }
}

struct PinCodeChangeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let buttonConfig: ButtonConfig = .init(
            font: .body,
            textColor: .black,
            buttonColor: .gray)
        let pinConfig: PinCodeView.PinCodeConfig =  .init(
            font: .body,
            foregroundColor: .yellow,
            colorsForPin: .init(
                normal: .gray,
                incorrect: .red,
                correct: .green,
                printing: .blue)
        )
        
        PinCodeChangeView(
            config: .init(
                buttonConfig: buttonConfig,
                pinCodeConfig: pinConfig),
            viewModel: .init(
                title: "String",
                pincodeLength: 4,
                confirmationPublisher: {
                    
                    Just(.init(value: "71234567899"))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }, 
                handler: {_,_ in }
            ),
            confirmationView: { Text($0.value) }
        )
    }
}
