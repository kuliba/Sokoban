//
//  AuthLoginView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2022.
//

import Combine
import Presentation
import SwiftUI
import UIPrimitives

struct AuthLoginView: View {
    
    @Environment(\.openURL) var openURL
    
    @ObservedObject var viewModel: AuthLoginViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            HeaderView(viewModel: viewModel.header)
            CardView(viewModel: viewModel.card)
        }
        .alert(item: viewModel.alertType, content: alert(forAlertType:))
        .present(item: $viewModel.cardScanner, style: .fullScreen) {
            
            CardScannerView(viewModel: $0)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

extension AuthLoginView {
    func alert(forAlertType alertType: AlertType) -> SwiftUI.Alert {
        
        return viewModel.swiftUIAlert(forAlertType: alertType) {
            
            viewModel.clientInformAlertButtonTapped { url in openURL(url) }
        }
    }
}

extension AuthLoginView {
    
    struct HeaderView: View {
        
        let viewModel: AuthLoginViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textH1Sb24322())
                        .foregroundColor(.textSecondary)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                
                Text(viewModel.subTitle)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
    }
    
    struct CardView: View {
        
        @ObservedObject var viewModel: AuthLoginViewModel.CardViewModel
        
        var textFieldFont: UIFont {
            
            let mainScreenWight = UIScreen.main.bounds.width > 640
            return mainScreenWight ?
                .monospacedSystemFont(ofSize: 20, weight: .regular) :
                .monospacedSystemFont(ofSize: 17, weight: .regular)
        }
        
        var body: some View {
            
            ZStack {
                
                // shadow
                RoundedRectangle(cornerRadius: 12)
                    .offset(.init(x: 0, y: 20))
                    .foregroundColor(.mainColorsBlackMedium)
                    .opacity(0.3)
                    .blur(radius: 16)
                    .padding(.horizontal, 46)
                    .frame(height: 204)
                
                // card
                ZStack {
                    
                    // background
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.cardClassic)
                    
                    VStack(spacing: 0) {
                        
                        // top icons
                        HStack {
                            
                            viewModel.icon
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.mainColorsWhite)
                            
                            Spacer()
                            
                            Button(action: viewModel.scanButton.action) {
                                
                                viewModel.scanButton.icon
                                    .foregroundColor(.mainColorsWhite)
                            }
                        }
                        
                        Spacer()
                        
                        // text field
                        ZStack {
                            
                            TextFieldMaskableView(viewModel: viewModel.textField, font: textFieldFont)
                                .textContentType(.creditCardNumber)
                            
                            HStack {
                                
                                Spacer()
                                
                                if let nextButton = viewModel.nextButton {
                                    
                                    Button(action: nextButton.action) {
                                        
                                        nextButton.icon
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 44, height: 44)
                                }
                            }
                        }
                        .frame(height: 28)
                        .padding(.bottom, 4)
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.mainColorsWhite)
                            .padding(.bottom, 28)
                        
                        HStack {
                            
                            Text(viewModel.subTitle)
                                .font(.textBodyMR14200())
                                .foregroundColor(.textWhite)
                            
                            Spacer()
                            
                        }
                        .padding(.bottom, 8)
                        
                    }
                    .padding(20)
   
                }
                .frame(height: 204)
                .padding(.horizontal, 20)
            }
        }
    }
}

struct AuthLoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AuthLoginView(viewModel: .preview)
    }
}
