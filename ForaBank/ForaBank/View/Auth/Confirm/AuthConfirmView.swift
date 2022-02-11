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
            
            HStack(alignment: .center){
                
                ZStack{
                    
                    Button{
                    
                        viewModel.navigationBar.backButton.action()
                    } label: {
                        
                        viewModel.navigationBar.backButton.icon
                    }
                }
                    
                Spacer()
                    
                Text(viewModel.navigationBar.title)
                    
                Spacer()
                    
                }
                
                CodeView(viewModel: viewModel.code)
                
                InfoView(viewModel: viewModel.info!)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 20, trailing: 20))
        
    }
}


extension AuthConfirmView {
    
    struct CodeView: View {
        
        @State var viewModel: AuthConfirmViewModel.CodeViewModel
        
            var body: some View {

            VStack(spacing: 32) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                    .padding([.leading,.trailing], 20)
                    .multilineTextAlignment(.center)
                
                    VStack(spacing: 8) {
                            HStack {
                                ForEach(0...6, id: \.self) { i in
                                    TextFieldView(viewModel: viewModel)
                                }
                            }
                    }
                }
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        }
    }
    
    struct InfoView: View {
        
        @State var viewModel: AuthConfirmViewModel.InfoViewModel
        
        
        var body: some View {

            VStack(spacing: 32) {
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
                    .padding([.leading,.trailing], 20)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                
                VStack {
                    
                    switch viewModel.state{
                    case .timer(let timer):
                        
                        Text(timer.value)
                            .font(.textH3R18240())
                            .foregroundColor(.textSecondary)
                    case .button(let button):
                        
                        Button {
                            
                            button.action()
                        } label: {
                            
                            Text(button.title)
                                .font(.textBodySR12160())
                        }
                        .frame(width: 140, height: 24, alignment: .center)
                        .background(Color.buttonSecondary)
                        .cornerRadius(90)
                        .font(.buttonMediumM14160())
                        .foregroundColor(.textRed)
                    }
                }
            }
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        }
    }
}


struct TextFieldView: View {
    
    @State var viewModel: AuthConfirmViewModel.CodeViewModel
    
    var body: some View {
        VStack{
            TextField("", text: $viewModel.code)
                .keyboardType(.numberPad)
                .font(.textH0B32402())
                .accentColor(.mainColorsGrayMedium)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .foregroundColor(.textPlaceholder)
            Capsule()
                .fill(Color.mainColorsGrayMedium)
                .frame(height: 1)
        }
    }
    
}

struct AuthConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        AuthConfirmView(viewModel: AuthConfirmViewModel())
    }
}
