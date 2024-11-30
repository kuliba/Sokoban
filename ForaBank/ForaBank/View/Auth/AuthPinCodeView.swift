//
//  PinCodeView.swift
//  ForaBank
//
//  Created by Дмитрий on 11.02.2022.
//

import SwiftUI

struct AuthPinCodeView: View {
    
    @Environment(\.openURL) var openURL

    @ObservedObject var viewModel: AuthPinCodeViewModel
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                PinCodeView(viewModel: viewModel.pinCode, mistakes: $viewModel.mistakes)
                    .padding(.top, 80)
                
                NumPadView(viewModel: viewModel.numpad)
                    .padding(.top, 52)
                
                Spacer()
                
                FooterView(viewModel: viewModel.footer)
            }
            .zIndex(0)
            
            NavigationLink("", isActive: $viewModel.isPermissionsViewPresented) {
                
                if let permissionViewModel = viewModel.permissionsViewModel {
                    
                    AuthPermissionsView(viewModel: permissionViewModel)
                        .zIndex(1)
                    
                } else {
                    
                    EmptyView()
                }
            }
            
            if let spinner = viewModel.spinner {
                
                SpinnerView(viewModel: spinner)
                    .zIndex(2)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .alert(item: viewModel.alertType, content: alert(forAlertType:))
        .onAppear {
            viewModel.action.send(AuthPinCodeViewModelAction.Appear())
        }
    }
}

extension AuthPinCodeView {
    func alert(forAlertType alertModelType: AlertModelType) -> SwiftUI.Alert {
        
        return viewModel.swiftUIAlert(forAlertModelType: alertModelType) {
            
            viewModel.clientInformAlertButtonTapped { url in openURL(url) }
        }
    }
}

//MARK: - Pincode

extension AuthPinCodeView {
    
    struct PinCodeView: View {
        
        @ObservedObject var viewModel: AuthPinCodeViewModel.PinCodeViewModel
        @Binding var mistakes: Int
        
        var body: some View {
            
            VStack(spacing: 40) {
                
                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 16) {
                    
                    ForEach(viewModel.dots.indices, id: \.self) { index in
                        
                        DotView(viewModel: viewModel.dots[index], style: viewModel.style, isAnimated: $viewModel.isAnimated, delay: TimeInterval(index) * 0.2)
                    }
                }
                .modifier(AuthPinCodeView.Shake(animatableData: CGFloat(mistakes)))
            }
        }
        
        struct DotView: View {
            
            let color: Color
            @Binding var isAnimated: Bool
            let size: CGFloat
            let duration: TimeInterval
            let delay: TimeInterval
            
            init(viewModel: AuthPinCodeViewModel.PinCodeViewModel.DotViewModel, style: AuthPinCodeViewModel.PinCodeViewModel.Style, isAnimated: Binding<Bool>, size: CGFloat = 12, duration: TimeInterval = 1.0, delay: TimeInterval = 0) {
                
                if viewModel.isFilled == true {
                    
                    switch style {
                    case .normal:
                        self.color = .mainColorsBlack
                        
                    case .correct:
                        self.color = .systemColorActive
                        
                    case .incorrect:
                        self.color = .systemColorError
                    }
                    
                } else {
                    
                    self.color = .mainColorsGrayMedium
                }
                
                self._isAnimated = isAnimated
                self.size = size
                self.duration = duration
                self.delay = delay
            }
            
            var body: some View {
                           
                Circle()
                    .frame(width: size, height: size)
                    .foregroundColor(color)
                    .scaleEffect(isAnimated ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay), value: isAnimated)
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
                                    .disabled(viewModel.isEnabled == false)
                                
                            case .icon(let icon):
                                ImageButtonView(icon: icon, action: button.action)
                                    .disabled(viewModel.isEnabled == false)
                                
                            case .text(let text):
                                TextButtonView(title: text, action: button.action)
                                    .disabled(viewModel.isEnabled == false)
                                
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
                    .font(.textBodyMSb14200())
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
                    .font(.textH4Sb16240())
                }
                
                Spacer()
                
                if let continueButton =  viewModel.continueButton{
                    
                    Button {
                        
                        continueButton.action()
                    } label: {
                        
                        Text(continueButton.title)
                    }
                    .foregroundColor(.textSecondary)
                    .font(.textH4Sb16240())
                }
            }
            .padding([.leading,.trailing, .bottom], 20)
        }
    }
}

//MARK: - Shake

extension AuthPinCodeView {
    
    struct Shake: GeometryEffect {
        
        var amount: CGFloat = 10
        var shakesPerUnit = 3
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            
            ProjectionTransform(CGAffineTransform(translationX:
                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
        }
    }
}

//MARK: - Preview

struct PinCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            AuthPinCodeView(viewModel: .sample)
            
            AuthPinCodeView.PinCodeView(viewModel: .empty, mistakes: .constant(0))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Empty")
            
            AuthPinCodeView.PinCodeView(viewModel: .editing, mistakes: .constant(0))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Editing")
            
            AuthPinCodeView.PinCodeView(viewModel: .correct, mistakes: .constant(0))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Correct")
            
            AuthPinCodeView.PinCodeView(viewModel: .incorrect, mistakes: .constant(0))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Incorrect")
            
            AuthPinCodeView.PinCodeView(viewModel: .correctAnimating, mistakes: .constant(0))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Pincode Correct Animating")
        }
    }
}
