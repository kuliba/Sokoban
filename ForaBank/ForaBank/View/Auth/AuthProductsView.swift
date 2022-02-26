//
//  AuthProductsView.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 11.02.2022.
//

import SwiftUI
import Combine

struct AuthProductsView: View {
    
    @ObservedObject var viewModel: AuthProductsViewModel
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 0) {
                
                ForEach(viewModel.productCards) { productCard in
                    ProductView(viewModel: productCard)
                }
                
                Spacer()
            }
        }
        .navigationBarTitle(Text(viewModel.navigationBar.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .foregroundColor(.black)
    }
}

extension AuthProductsView {
    
    var btnBack : some View {
        Button(action: viewModel.navigationBar.backButton.action) {
            HStack {
                viewModel.navigationBar.backButton.icon
                    .foregroundColor(.black)
            }
        }
    }
    
    struct ProductView: View {
        
        @ObservedObject var viewModel: AuthProductsViewModel.ProductCard
        
        var body: some View {
            
            ZStack {
                
                viewModel.style.backgroundColor
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.title)
                        .font(.textH0B32402())
                        .foregroundColor(viewModel.style.textColor)
                        .padding(.top, 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        ForEach(viewModel.subtitle, id: \.self) { line in
                           
                            Text(line)
                                .font(.textBodyMR14200())
                                .foregroundColor(viewModel.style.textColor)
                                
                        }
                        
                    }.padding(.top, 24)
 
                    switch viewModel.image {
                    case .image(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .padding(.top, 20)
                        
                    case .endpoint:
                        Color
                            .mainColorsGrayMedium
                            .opacity(0.5)
                            .frame(height: 236)
                            .cornerRadius(12)
                            .padding(.top, 20)
                    }
         
                    HStack(alignment: .center, spacing: 20) {
                        
                        AuthProductsView.InfoButtonView(viewModel: viewModel.infoButton, color: viewModel.style.textColor)
                        
                        Spacer()
                        
                        AuthProductsView.OrderButtonView(viewModel: viewModel.orderButton)
                    }
                    .frame(height: 48)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    struct InfoButtonView: View {
        
        let viewModel: AuthProductsViewModel.ProductCard.InfoButton
        
        let color: Color
        
        var body: some View {
            
            if #available(iOS 14.0, *) {
                
                Link(destination: viewModel.url) {
                    
                    HStack {
                        
                        viewModel.icon
                            .foregroundColor(color)
                        
                        Text(viewModel.title)
                            .foregroundColor(color)
                            .multilineTextAlignment(.leading)
                    }
                }
                
            } else {
                
                Button{
                    
                    UIApplication.shared.open(viewModel.url)
                    
                } label: {
                    
                    HStack {
                        
                        viewModel.icon
                            .foregroundColor(color)
                        
                        Text(viewModel.title)
                            .foregroundColor(color)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }
    
    struct OrderButtonView: View {
        
        let viewModel: AuthProductsViewModel.ProductCard.OrderButton
        
        var body: some View {
            
            if #available(iOS 14.0, *) {
                
                Link(destination: viewModel.url) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.textWhite)
                        .padding(.vertical, 12)
                        .frame(width: 166)
                        .background(Color.buttonPrimary)
                        .cornerRadius(8)
                }
                
            } else {
                
                Button{
                    
                    UIApplication.shared.open(viewModel.url)
                    
                } label: {
                    
                    Text(viewModel.title)
                        .foregroundColor(.textWhite)
                        .padding(.vertical, 12)
                        .frame(width: 166)
                        .background(Color.buttonPrimary)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct AuthProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            AuthProductsView(viewModel: .mockData)
        }
    }
}
