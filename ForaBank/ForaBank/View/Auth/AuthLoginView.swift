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
            
            if let productsButtonViewModel = viewModel.productsButton {
                
                ProductsButtonView(viewModel: productsButtonViewModel)
            }

            NavigationLink("", isActive: $viewModel.isConfirmViewPresented) {
                
                if let confirmViewModel = viewModel.confirmViewModel {
                    
                    AuthConfirmView(viewModel: confirmViewModel)
                    
                } else {
                    
                    EmptyView()
                }
            }
            
            NavigationLink("", isActive: $viewModel.isProductsViewPresented) {
                
                if let productsViewModel = viewModel.productsViewModel {
                    
                    AuthProductsView(viewModel: productsViewModel)
                    
                } else {
                    
                    EmptyView()
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
                            
                            TextFieldMaskableView(viewModel: viewModel.textField)
                                .font(.textH2M20282())
                                .textContentType(.creditCardNumber)
                            
                            HStack {
                                
                                Spacer()
                                
                                if let nextButton = viewModel.nextButton {
                                    
                                    Button(action: nextButton.action) {
                                        
                                        nextButton.icon
                                            .foregroundColor(.white)
                                    }
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
        
        var viewModel: AuthLoginViewModel.ProductsButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                HStack(alignment: .center) {
                    
                    viewModel.icon
                        .renderingMode(.original)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text(viewModel.title)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textWhite)
                        
                        Text(viewModel.subTitle)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textWhite)
                    }
                    
                    Spacer()
                    
                    viewModel.arrowRight
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

struct AuthLoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        AuthLoginView(viewModel: .init(.emptyMock, rootActions: .emptyMock))
    }
}

