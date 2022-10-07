//
//  AuthLoginView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2022.
//

import SwiftUI
import Combine
import Presentation

struct AuthLoginView: View {
    
    @ObservedObject var viewModel: AuthLoginViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            HeaderView(viewModel: viewModel.header)
            CardView(viewModel: viewModel.card)
            
            Spacer()
            
            ProductsButtonView(viewModel: viewModel.products)

            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case let .confirm(confirmViewModel):
                        AuthConfirmView(viewModel: confirmViewModel)
                        
                    case let .products(productsViewModel):
                        AuthProductsView(viewModel: productsViewModel)
                    }
                }
            }
        }
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
        .present(item: $viewModel.cardScanner, style: .fullScreen, content: { cardScannerViewModel in
            
            CardScannerView(viewModel: cardScannerViewModel)
                .edgesIgnoringSafeArea(.all)
        })
        .padding(.top, 24)
        .background(
            Image.imgRegistrationBg
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

extension AuthLoginView {
    
    struct HeaderView: View {
        
        let viewModel: AuthLoginViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textH1SB24322())
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
    
    struct ProductsButtonView: View {
        
        @ObservedObject var viewModel: AuthLoginViewModel.ProductsViewModel
        
        var body: some View {
            
            if let button = viewModel.button  {
                
                Button(action: button.action) {
                    
                    HStack(alignment: .center) {
                        
                        button.icon
                            .renderingMode(.original)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            
                            Text(button.title)
                                .font(.textBodyMR14200())
                                .foregroundColor(.textWhite)
                            
                            Text(button.subTitle)
                                .font(.textBodyMR14200())
                                .foregroundColor(.textWhite)
                        }
                        
                        Spacer()
                        
                        button.arrowRight
                            .foregroundColor(.mainColorsWhite)
                        
                    }
                    
                    .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                    .background(Color.mainColorsBlackMedium)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct AuthLoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        AuthLoginView(viewModel: .init(.emptyMock, rootActions: .emptyMock))
    }
}

