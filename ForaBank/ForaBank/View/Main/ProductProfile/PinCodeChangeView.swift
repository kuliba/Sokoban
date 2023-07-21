//
//  PinCodeChangeView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 13.07.2023.
//

import SwiftUI
import PinCodeUI

struct PinCodeChangeView: View {
    
    let viewModel: PinCodeViewModel
    @State private var showingConfirmView = false
    private var string: Binding<String>
    
    init(
        viewModel: PinCodeViewModel
    ) {
        self.viewModel = viewModel
        self.string = Binding(
            get: { viewModel.state.code },
            set: { newValue in
           
                viewModel.state.code = newValue
        })
    }

    var body: some View {
        
        VStack(alignment: .center, spacing: 52) {
            
            PinCodeView(
                viewModel: viewModel,
                config: viewModel.config.pinCodeConfig)
            KeyPad(
                string: string,
                config: viewModel.config.buttonConfig,
                deleteImage: .ic40Delete,
                pinCodeLength: viewModel.pincodeLength,
                action: {
                    
                    viewModel.confirm()
                    if viewModel.state.currentStyle == .correct {
                        
                        showingConfirmView.toggle()
                    }
                    
                }
            )
            .fixedSize()
            .fullScreenCover(isPresented: $showingConfirmView) {
                NavigationView {
                    
                    PinCodeUI.ConfirmView()
                        .toolbar {
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                
                                Button(
                                    action: {
                                        showingConfirmView.toggle()
                                        viewModel.resetState()
                                    },
                                    label: {
                                        Image.ic24ChevronLeft                .aspectRatio(contentMode: .fit)
                                    }
                                )
                                .buttonStyle(.plain)
                            }
                        }
                }
            }
            Spacer()
        }
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
            viewModel: .init(
                title: "String",
                pincodeLength: 4,
                config: .init(
                    buttonConfig: buttonConfig,
                    pinCodeConfig: pinConfig)
            )
        )
    }
}
