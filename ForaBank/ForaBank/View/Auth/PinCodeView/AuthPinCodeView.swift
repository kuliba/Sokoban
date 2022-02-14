//
//  PinCodeView.swift
//  ForaBank
//
//  Created by Дмитрий on 11.02.2022.
//

import SwiftUI

struct AuthPinCodeView: View {
    
    @ObservedObject var viewModel: AuthPinCodeViewModel
    
    var body: some View {
        
        VStack() {
            
            PinCodeView(viewModel: viewModel.pinCode)
            
            NumPadView(viewModel: viewModel.numpad)
            
            Spacer()
            
            ButtonsView(viewModel: viewModel.bottomButton)
        }
        .padding([.top], 80)
    }
}


extension AuthPinCodeView{
    
    struct NumPadView: View {
        
        @ObservedObject var viewModel: AuthPinCodeViewModel.NumPadViewModel
        
        var body: some View {
            
            VStack(spacing: 24){
                
                ForEach(viewModel.buttons, id: \.self) { row in
                    
                    HStack(spacing: 20){
                        
                        ForEach(row, id: \.self){ button in
                            
                            if let button = button {
                                
                                switch button.type {
                                    
                                case .digit(let title):
                                    
                                    DigitButtonView(id: button.id, title: title, action: button.action)
                                case .icon(let icon):
                                    
                                    ImageButtonView(id: button.id, image: icon, action: button.action)
                                case .text(let text):
                                    
                                    TextButtonView(id: button.id, title: text, action: button.action)
                                }
                            } else {
                                Color.white
                                    .frame(width: 80, height: 80, alignment: .center)
                            }
                        }
                    }
                }
            }
        }
        
        struct DigitButtonView: View {
            
            let id: AuthPinCodeViewModel.ButtonViewModel.ID
            let title: String
            let action: (AuthPinCodeViewModel.ButtonViewModel.ID) -> Void
            
            var body: some View{
                Button(action: { action(id) }) {
                    
                    Color.mainColorsGrayLightest
                        .overlay(
                            Text(title)
                                .font(.textH1R24322())
                        )
                        .foregroundColor(Color.textSecondary)
                }
                .cornerRadius(50)
                .frame(width: 80, height: 80, alignment: .center)
            }
        }
        
        struct ImageButtonView: View {
            
            let id: AuthPinCodeViewModel.ButtonViewModel.ID
            let image: Image
            let action: (AuthPinCodeViewModel.ButtonViewModel.ID) -> Void
            
            var body: some View{
                Button(action: { action(id) }) {
                    image
                        .renderingMode(.original)
                        .foregroundColor(Color.textSecondary)
                }
                .frame(width: 80, height: 80, alignment: .center)
            }
        }
        
        
        struct TextButtonView: View {
            
            let id: AuthPinCodeViewModel.ButtonViewModel.ID
            let title: String
            let action: (AuthPinCodeViewModel.ButtonViewModel.ID) -> Void
            
            var body: some View{
                Button(action: { action(id) }) {
                    
                    Color.mainColorsGrayLightest
                        .overlay(
                            Text(title)
                                .font(.textBodyMSB14200())
                        )
                        .foregroundColor(Color.textSecondary)
                }
                .cornerRadius(50)
                .frame(width: 80, height: 80, alignment: .center)
            }
        }
    }
    
    
    struct ButtonsView: View {
        
        let viewModel: AuthPinCodeViewModel.FooterViewModel
        
        var body: some View {
            
            HStack {
                
                if let cancelButton =  viewModel.cancelButton {
                    
                    Button {
                        
                        cancelButton.action()
                    } label: {
                        
                        Text(cancelButton.title)
                    }
                    .foregroundColor(.textSecondary)
                    .font(.textH4SB16240())
                }
                
                Spacer()
                
                if let continueButton =  viewModel.continueButton{
                    
                    Button {
                        
                        continueButton.action()
                    } label: {
                        
                        Text(continueButton.title)
                    }
                    .foregroundColor(.textSecondary)
                    .font(.textH4SB16240())
                }
            }
            .padding([.leading,.trailing, .bottom], 20)
        }
    }
    
    struct PinCodeView: View {
        
        var viewModel: AuthPinCodeViewModel.PinCodeViewModel
        
        var body: some View {
            
            Text(viewModel.title)
                .font(.textH4M16240())
                .padding([.bottom], 40)
            
            HStack(alignment: .center, spacing: 16){
                
                ForEach(viewModel.code, id: \.self) { pin in
                    
                    switch viewModel.state{
                        
                    case .editing:
                        
                        Circle()
                            .frame(width: 12, height: 12, alignment: .center)
                            .foregroundColor(.mainColorsGrayMedium)
                    case .incorrect:
                        
                        Circle()
                            .frame(width: 12, height: 12, alignment: .center)
                            .foregroundColor(.systemColorError)
                    case .correct:
                        
                        Circle()
                            .frame(width: 12, height: 12, alignment: .center)
                            .foregroundColor(.systemColorActive)
                    }
                    
                }
            }
            .padding([.bottom], 52)
        }
    }
}

struct PinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        AuthPinCodeView(viewModel: AuthPinCodeViewModel())
    }
}
