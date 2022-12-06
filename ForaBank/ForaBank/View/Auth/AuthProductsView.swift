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
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
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
        Button {
                mode.wrappedValue.dismiss()
                viewModel.navigationBar.backButton.action()
        } label: {
            
            HStack {
                viewModel.navigationBar.backButton.icon
                    .foregroundColor(.black)
            }
        }
    }
    
    struct ProductView: View {
        
        @ObservedObject var viewModel: AuthProductsViewModel.ProductCardViewModel
        
        var body: some View {
            
            ZStack {
                
                viewModel.style.backgroundColor
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.title)
                        .font(.textH0B32402())
                        .foregroundColor(viewModel.style.textColor)
                        .padding(.top, 32)
                    
                    if let conditionViewModel = viewModel.conditionViewModel {
                     
                        HStack(spacing: 16) {
                            Text(conditionViewModel.percent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundColor(.white)
                                .background(Color.mainColorsRed)
                                .cornerRadius(4)
                                .font(.system(size: 14))
                            
                            Text(conditionViewModel.amount)
                                .font(.system(size: 14))

                            Color(.black)
                                .frame(width: 1, alignment: .center)
                                .padding(.vertical, 3)
                            
                            Text(conditionViewModel.date)
                                .font(.system(size: 14))
                        }
                        .frame(height: 24, alignment: .leading)
                        .padding(.top, 24)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        ForEach(viewModel.subtitle, id: \.self) { line in
                            
                            HStack(alignment: .firstTextBaseline) {
                                
                                Circle()
                                    .frame(width: 4, height: 4)
                                    .foregroundColor(viewModel.style.textColor)
                                    .frame(width: 11, height: 11)
                                
                                Text(line)
                                    .font(.textBodyMR14200())
                                    .foregroundColor(viewModel.style.textColor)
                                
                                Spacer()
                            }
                        }
                    }.padding(.top, 24)
                    
                    Group {
                        switch viewModel.image {
                        case .image(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                            
                        case .endpoint:
                            Color
                                .mainColorsGrayMedium
                                .opacity(0.5)
                                .frame(height: 236)
                                .cornerRadius(12)
                        }
                    }.padding(.top, 20)
                    
                    HStack(alignment: .center, spacing: 16) {
                        
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
        
        let viewModel: AuthProductsViewModel.ProductCardViewModel.InfoButton
        
        let color: Color
        
        var body: some View {
            
            Link(destination: viewModel.url) {
                
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
    
    struct OrderButtonView: View {
        
        let viewModel: AuthProductsViewModel.ProductCardViewModel.OrderButton
        
        var body: some View {
            
            Link(destination: viewModel.url) {
                
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

struct AuthProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            AuthProductsView(viewModel: .mockData)
        }
    }
}
