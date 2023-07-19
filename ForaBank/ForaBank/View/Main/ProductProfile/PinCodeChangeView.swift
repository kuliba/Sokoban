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
    @State private var string = ""
    @State private var showingConfirmView = false
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 52) {
            
            PinCodeView(
                viewModel: viewModel,
                config: viewModel.config.pinCodeConfig)
            KeyPad(
                string: $string,
                config: viewModel.config.buttonConfig,
                deleteImage: .ic40Delete,
                pinCodeLength: viewModel.pincodeLength,
                action: {
                    //TODO: упростить!!!
                    viewModel.updateView(codeValue: string, codeLength: viewModel.pincodeLength)
                    
                    if viewModel.needClearDots {
                        string = ""
                        viewModel.updateView(codeValue: string, codeLength: viewModel.pincodeLength)
                    }
                    if viewModel.state.currentStyle == .incorrect {
                        //TODO: добавить обработку ошибок для аннимации
                    }
                    //TODO: - исправить!!! сделано для показа
                    if viewModel.state.currentStyle == .correct {
                        
                        showingConfirmView.toggle()
                    }
                }
            )
            .fixedSize()
            .fullScreenCover(isPresented: $showingConfirmView) {
                //TODO: - исправить!!! сделано для показа
                NavigationView {
                    
                    PinCodeUI.ConfirmView()
                        .toolbar {
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                
                                Button(
                                    action: {
                                        showingConfirmView.toggle()
                                        string = ""
                                        viewModel.updateView(codeValue: string, codeLength: viewModel.pincodeLength)
                                        viewModel.state = .init(state: .empty, title: viewModel.title)
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
