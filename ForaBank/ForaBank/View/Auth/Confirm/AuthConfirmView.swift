//
//  AuthConfirmView.swift
//  ForaBank
//
//  Created by Дмитрий on 10.02.2022.
//

import SwiftUI

struct AuthConfirmView: View {
    
    var viewModel: AuthConfirmViewModel

    var body: some View {
        
            VStack{
                
                HStack{
                    
                    Button {
                        
                        viewModel.navigationBar.backButton.action()
                    } label: {
                        viewModel.navigationBar.backButton.icon
                    }
                    Spacer()
                    Text(viewModel.navigationBar.title)
                    
                }
                
                CodeView(viewModel: viewModel.code)
                
                InfoViewModel(viewModel: viewModel.info!)
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
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
                
                TextField("", text: .bindOptional($viewModel.code, ""))
                    .border(Color.mainColorsGrayMedium, width: 1)
                    .keyboardType(.numberPad)
                    .font(.textH0B32402())
                    .textFieldStyle(.roundedBorder)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [11.0]))
                    )
                }
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        }
    }
    
    struct InfoViewModel: View {
        
        @State var viewModel: AuthConfirmViewModel.InfoViewModel
        
        var body: some View {

            VStack(spacing: 5) {
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textSecondary)
                    .padding([.leading,.trailing], 20)
                    .multilineTextAlignment(.center)
                
                
                
                Button {
                    print("")
                } label: {
                    Text("Отправить повторно")
                }
                .frame(width: 140, height: 24, alignment: .center)
                .background(Color.buttonSecondary)
                .cornerRadius(90)
                .font(.buttonMediumM14160())
                .foregroundColor(.textRed)

            }
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        }
    }
}

struct AuthConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        AuthConfirmView(viewModel: AuthConfirmViewModel())
    }
}
