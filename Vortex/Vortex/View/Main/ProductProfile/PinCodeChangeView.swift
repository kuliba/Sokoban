//
//  PinCodeChangeView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 13.07.2023.
//

import Combine
import SwiftUI
import PinCodeUI
import Tagged

struct PinCodeChangeView<ConfirmationView: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject private var viewModel: PinCodeViewModel
    
    private let config: PinCodeView.Config
    private let confirmationView: (PinCodeViewModel.PhoneNumber, PinDomain.NewPin) -> ConfirmationView
    
    init(
        config: PinCodeView.Config,
        viewModel: PinCodeViewModel,
        confirmationView: @escaping (PinCodeViewModel.PhoneNumber, PinDomain.NewPin) -> ConfirmationView
    ) {
        self.config = config
        self.viewModel = viewModel
        self.confirmationView = confirmationView
    }
    
    var body: some View {
        
        if let phone = viewModel.phoneNumber {
            
            confirmationView(
                .init(value: viewModel.phoneNumber?.value ?? "default"),
                .init(viewModel.state.code)
            )
            
        } else {
            
            VStack(alignment: .center) {
                
                Button(
                    action: { self.presentationMode.wrappedValue.dismiss() },
                    label: {
                        Image.ic24ChevronLeft
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                    }
                )
                .buttonStyle(.plain)
                .padding(.top, 12)
                .padding(.leading, 20)
                .maxWidthLeadingFrame()
                
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
                
                Spacer()
            }
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
                getPinConfirm: {_ in }
            ),
            confirmationView: { phone, code in
                VStack {
                    Text(phone.value)
                    Text(code.rawValue)
                }
            }
        )
    }
}
