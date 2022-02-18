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
        
        VStack(spacing: 0) {
            
            PinCodeView(viewModel: viewModel.pinCode)
                .padding(.top, 80)
            
            NumPadView(viewModel: viewModel.numpad)
                .padding(.top, 52)
            
            Spacer()
            FooterView(viewModel: viewModel.footer)
        }
        .navigationBarHidden(true)
    }
}

//MARK: - Pincode

extension AuthPinCodeView {
    
    struct PinCodeView: View {
        
        @ObservedObject var viewModel: AuthPinCodeViewModel.PinCodeViewModel
        
        var body: some View {
            
            VStack(spacing: 40) {
                
                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 16) {
                    
                    ForEach(viewModel.dots, id: \.self) { dotViewModel in
                        
                        DotView(viewModel: dotViewModel, state: viewModel.state)
                    }
                }
            }
        }
        
        struct DotView: View {
            
            let color: Color
            
            init(viewModel: AuthPinCodeViewModel.PinCodeViewModel.DotViewModel, state: AuthPinCodeViewModel.PinCodeViewModel.State) {
                
                switch viewModel {
                case .empty:
                    self.color = .mainColorsGrayMedium
                    
                case .filled:
                    switch state {
                    case .editing:
                        self.color = .mainColorsBlack
                        
                    case .correct:
                        self.color = .systemColorActive
                        
                    case .incorrect:
                        self.color = .systemColorError
                    }
                }
            }
            
            var body: some View {
                
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(color)
            }
        }
 
    }
}

//MARK: - Numpad

extension AuthPinCodeView {
    
    struct NumPadView: View {
        
        @ObservedObject var viewModel: AuthPinCodeViewModel.NumPadViewModel
        
        var body: some View {
            
            VStack(spacing: 24){
                
                ForEach(viewModel.buttons, id: \.self) { row in
                    
                    HStack(spacing: 20) {
                        
                        ForEach(row) { button in
                            
                            switch button.type {
                            case .digit(let title):
                                DigitButtonView(title: title, action: button.action)
                                
                            case .icon(let icon):
                                ImageButtonView(icon: icon, action: button.action)
                                
                            case .text(let text):
                                TextButtonView(title: text, action: button.action)
                                
                            case .empty:
                                Color.clear
                                    .frame(width: 80, height: 80)
                                
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Numpad Buttons

extension AuthPinCodeView.NumPadView {
    
    struct DigitButtonView: View {
        
        let title: String
        let action: () -> Void
        
        var body: some View{
            
            Button(action: action) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    Text(title)
                        .font(.textH1R24322())
                        .foregroundColor(Color.textSecondary)
                }
            }
            .frame(width: 80, height: 80)
        }
    }
    
    struct ImageButtonView: View {
        
        let icon: Image
        let action: () -> Void
        
        var body: some View{
            
            Button(action: action) {
                
                icon.foregroundColor(Color.textSecondary)
            }
            .frame(width: 80, height: 80)
        }
    }
    
    struct TextButtonView: View {
        
        let title: String
        let action: () -> Void
        
        var body: some View{
            
            Button(action: action) {
                
                Text(title)
                    .font(.textBodyMSB14200())
                    .foregroundColor(.textSecondary)
            }
            .frame(width: 80, height: 80)
        }
    }
}

//MARK: - Footer

extension AuthPinCodeView {
    
    struct FooterView: View {
        
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
}

//MARK: - Preview

struct PinCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            AuthPinCodeView(viewModel: .sample)
            
            AuthPinCodeView.PinCodeView(viewModel: .empty)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Empty")
            
            AuthPinCodeView.PinCodeView(viewModel: .editing)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Empty")
            
            AuthPinCodeView.PinCodeView(viewModel: .correct)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Empty")
            
            AuthPinCodeView.PinCodeView(viewModel: .incorrect)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Empty")
        }
    }
}
