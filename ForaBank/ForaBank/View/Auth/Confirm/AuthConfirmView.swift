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
        NavigationView {
            
            if #available(iOS 14.0, *) {
                
                VStack {
                    CodeView(viewModel: viewModel.code)
                    
                    if let info = viewModel.info{
                        
                        InfoView(viewModel: info)
                    }
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 20, trailing: 20))
                .navigationBarItems(leading:
                                        
                                        Button(action: {
                    viewModel.navigationBar.backButton.action()
                }) {
                    viewModel.navigationBar.backButton.icon
                        .renderingMode(.original)
                }
                ).navigationBarBackButtonHidden(true)
                    .navigationBarTitle(viewModel.navigationBar.title)
                    .navigationBarTitleDisplayMode(.inline)
                    
            } else {
                
                VStack {
                    CodeView(viewModel: viewModel.code)
                    
                    if let info = viewModel.info{
                        
                        InfoView(viewModel: info)
                    }
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 20, trailing: 20))
                .navigationBarItems(leading:
                                        
                                        Button(action: {
                    viewModel.navigationBar.backButton.action()
                }) {
                    viewModel.navigationBar.backButton.icon
                        .renderingMode(.original)
                }
                ).navigationBarBackButtonHidden(true)
                    .navigationBarTitle(Text(viewModel.navigationBar.title), displayMode: .inline)
            }
        }
    }
}


extension AuthConfirmView {
    
    struct CodeView: View {
        
        var viewModel: AuthConfirmViewModel.CodeViewModel
        
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
        
        var viewModel: AuthConfirmViewModel.InfoViewModel
        
        
        var body: some View {
            
            VStack(spacing: 32) {
                
                switch viewModel.state{
                case .timer(let timer):
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textPlaceholder)
                        .padding([.leading,.trailing], 20)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                    
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
            .padding([.top, .bottom],20)
        }
    }
}

struct AuthConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        AuthConfirmView(viewModel: AuthConfirmViewModel())
    }
}
