//
//  AuthConfirmView.swift
//  ForaBank
//
//  Created by Дмитрий on 10.02.2022.
//

import SwiftUI

struct AuthConfirmView: View {
    
    @ObservedObject var viewModel: AuthConfirmViewModel
    
    var body: some View {
        
        VStack {
            
            CodeView(viewModel: viewModel.code)
            
            if let info = viewModel.info {
                
                InfoView(viewModel: info)
            }
            
            ZStack {
                
                CustomTextField(text: $viewModel.code.textFieldCode, isFirstResponder: $viewModel.code.showKeyboard)
                
                Color.white
            }
            
            Spacer()
            
            NavigationLink("", isActive: $viewModel.isPincodeViewPresented) {
                
                if let pincodeViewModel = viewModel.pincodeViewModel {
                    
                    AuthPinCodeView(viewModel: pincodeViewModel)
                    
                } else {
                    
                    EmptyView()
                }
            }
        }
//        .alert(isPresented: $viewModel.showingAlert) {
//            if viewModel.codeAttemtsCount > 0 {
//                return Alert(title: Text("Введен некорректный код. Попробуйте еще раз."),
//                      message: Text("Осталось попыток: " + String(viewModel.codeAttemtsCount)),
//                      dismissButton: .default(Text("ОК"), action: {
//                    viewModel.code.state = .edit
//                    viewModel.codeAttemtsCount -= 1
//                }))
//            }
//            return Alert(title: Text("Ошибка"),
//                  message: Text("Вы исчерпали все попытки :("),
//                  dismissButton: .default(Text("ОК"), action: {
//                viewModel.navigationBar.backButton.action()
//            }))
//        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 20, trailing: 20))
        .navigationBarItems(leading: Button(action: {
            viewModel.code.showKeyboard = false
            viewModel.navigationBar.backButton.action() }) { viewModel.navigationBar.backButton.icon })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(viewModel.navigationBar.title), displayMode: .inline)
        .onAppear {
            
            viewModel.action.send(AuthConfirmViewModelAction.ViewDidAppear())
        }
    }
}


extension AuthConfirmView {
    
    struct CodeView: View {
        
        @ObservedObject var viewModel: AuthConfirmViewModel.CodeViewModel
        
        var body: some View {
            
            VStack(spacing: 32) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                    .padding([.leading,.trailing], 20)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16){
                    
                    ForEach(viewModel.code.indices, id: \.self) { index in
                        
                        DigitView(value: viewModel.code[index])
                        
                    }
                }
            }
            .padding(EdgeInsets(top: 24, leading: 20, bottom: 20, trailing: 20))
        }
        
        struct DigitView: View {
            
            let value: String?
            
            var body: some View {
                
                VStack{
                    
                    if let value = value {
                        
                        Text(value)
                            .foregroundColor(Color.textPlaceholder)
                            .font(.textH0B32402())
                    }
                    
                    Spacer()
                    Capsule()
                        .fill(Color.mainColorsGrayMedium)
                        .frame(height: 1)
                }
                .frame(height: 50)
            }
        }
    }
    
    struct InfoView: View {
        
        @ObservedObject var viewModel: AuthConfirmViewModel.InfoViewModel
    
        var body: some View {
            
            VStack(spacing: 32) {
                
                VStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textPlaceholder)
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = viewModel.subtitle {
                        
                        Text(subtitle)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textPlaceholder)
                            .multilineTextAlignment(.center)
                    }
                }
                
                switch viewModel.state {
                case .timer(let timerViewModel):
                    TimerView(viewModel: timerViewModel)
                    
                case .button(let button):
                    
                    Button(action: button.action) {
                        
                        Text(button.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.textRed)
                            .padding(10)
                    }
                    .background(Color.buttonSecondary)
                    .cornerRadius(8)
                }
            }
            .padding(20)
        }
        
        struct TimerView: View {
            
            @ObservedObject var viewModel: AuthConfirmViewModel.InfoViewModel.TimerViewModel
            
            var body: some View {
                
                Text(viewModel.value)
                    .font(.textH3R18240())
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct CustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        @Binding var didBecomeFirstResponder: Bool

        init(text: Binding<String>, didBecomeFirstResponder: Binding<Bool>) {
            _text = text
            _didBecomeFirstResponder = didBecomeFirstResponder
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }

    @Binding var text: String
    @Binding var isFirstResponder: Bool

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, didBecomeFirstResponder: $isFirstResponder)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        uiView.keyboardType = .numberPad
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        } else {
            uiView.resignFirstResponder()
            context.coordinator.didBecomeFirstResponder = false
        }
    }
}

struct AuthConfirmView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            AuthConfirmView(viewModel: .sampleConfirm)
        }
    }
}
