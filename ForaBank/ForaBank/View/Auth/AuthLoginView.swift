//
//  AuthLoginView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2022.
//

import SwiftUI
import Combine

//BackgroundLine

struct AuthLoginView: View {
    
    var viewModel: AuthLoginViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            HeaderView(viewModel: viewModel.header)
            CardView(viewModel: viewModel.card)
            Spacer()
            ProductsButtonView(viewModel: viewModel.productsButton)
            
        }
        .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        .background(
            Image("BackgroundLine")
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                    
                    viewModel.icon
                        .resizable()
                        .frame(width:16, height:16)
                }
                
                Text(viewModel.subTitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#1C1C1C"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
    }
    
    struct CardView: View {
        
        @State var viewModel: AuthLoginViewModel.CardViewModel
        
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
        
        var body: some View {
            VStack(spacing: 0) {
                
                HStack{
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                    
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
                    
                    TextField("", value: $viewModel.cardNumber, formatter: formatter)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .keyboardType(.numberPad)
                        .textContentType(.creditCardNumber)
                    
                    HStack{
                        
                        Spacer()
                        if viewModel.cardNumber?.count == 16 || viewModel.cardNumber?.count == 20{
                            Button {
                                
                                viewModel.nextButton.action()
                                
                            } label: {
                                
                                viewModel.nextButton.icon
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
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 28, leading: 20, bottom: 28, trailing: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .background(Color(hex: "#FF3636"))
            .cornerRadius(12)
            .clipped()
            .shadow(color: Color(hex: "#3D3D45").opacity(0.3), radius: 12, x: -10, y: 8)
            .frame(width: .infinity, height: 204, alignment: .top)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 19))
        }
    }
    
    struct ProductsButtonView: View {
        
        var viewModel: AuthLoginViewModel.ProductsButtonViewModel
        
        var body: some View {
            Button(action: {
            }) {
                
                VStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    HStack(alignment: .center) {
                        viewModel.icon
                        VStack(alignment: .leading ,spacing: 6) {
                            Text(viewModel.title)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                            Text(viewModel.subTitle)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
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
                    
                    Spacer()
                    
                }
                .background(Color(hex: "#3D3D45"))
                .cornerRadius(12)
                .frame(width: .infinity, height: 72, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 19))
            }
        }
    }
}


struct AuthLoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        AuthLoginView(viewModel: AuthLoginViewModel())
    }
}
