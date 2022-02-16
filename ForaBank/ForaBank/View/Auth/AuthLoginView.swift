//
//  AuthLoginView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2022.
//

import SwiftUI
import Combine

struct AuthLoginView: View {
    
    @ObservedObject var viewModel: AuthLoginViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            HeaderView(viewModel: viewModel.header)
            CardView(viewModel: $viewModel.card)
            
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
        .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        .background(
            Image.imgRegistrationBg
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
        )
    }
}

extension AuthLoginView {
    
    struct HeaderView: View {
        
        var viewModel: AuthLoginViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textH1SB24322())
                        .foregroundColor(.textSecondary)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width:16, height:16)
                }
                
                Text(viewModel.subTitle)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .trailing], 20)
        }
    }
    
    struct CardView: View {
        
        @Binding var viewModel: AuthLoginViewModel.CardViewModel
        @State private var message = ""
        @State private var isValidate: Bool = false


        var body: some View {
            VStack(spacing: 0) {
                
                HStack{
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        
                        viewModel.scanButton.action()
                        
                    } label: {
                        
                        viewModel.scanButton.icon
                            .foregroundColor(.white)
                        
                    }
                }
                .padding(20)
                
                Spacer()
                
                ZStack {
                    
                    TextView(text: $message, isValidate: isValidate)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .font(.textH2M20282())
                        .textContentType(.creditCardNumber)
                        
                    
                    HStack{
                        
                        Spacer()

                        if let nextButton = viewModel.nextButton{
                            
                            Button {
                                
                                nextButton.action()
                                
                            } label: {
                                
                                nextButton.icon
                                    .foregroundColor(.white)
                            }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                        }
                    }
                    
                }
                
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                    .background(Color.white)
                    .padding(EdgeInsets(top: 4, leading: 20, bottom: 0, trailing: 20))
                
                Text(viewModel.subTitle)
                    .font(.textBodyMR14200())
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 28, leading: 20, bottom: 28, trailing: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .background(Color.cardClassic)
            .cornerRadius(12)
            .clipped()
            .shadow(color: Color.mainColorsBlackMedium.opacity(0.3), radius: 12, x: -10, y: 8)
            .frame(width: .infinity, height: 204, alignment: .top)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 19))
        }
    }
    
    struct ProductsButtonView: View {
        
        var viewModel: AuthLoginViewModel.ProductsButtonViewModel
        
        var body: some View {
            
            Button(action: {
                
                viewModel.action()
            }) {
                    
                    HStack(alignment: .center) {
                        
                        viewModel.icon
                            .renderingMode(.original)
                        
                        VStack(alignment: .leading ,spacing: 6) {
                            
                            Text(viewModel.title)
                                .foregroundColor(.white)
                                .font(.textBodyMR14200())

                            Text(viewModel.subTitle)
                                .foregroundColor(.white)
                                .font(.textBodyMR14200())
                        }
                        
                        Spacer()
                        
                        Button {
                            
                            viewModel.action()
                            
                        } label: {
                            
                            viewModel.arrowRight
                                .foregroundColor(.white)
                            
                        }.padding(6)
                    }
                    .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.mainColorsBlackMedium)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}


struct AuthLoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        AuthLoginView(viewModel: AuthLoginViewModel())
    }
}

