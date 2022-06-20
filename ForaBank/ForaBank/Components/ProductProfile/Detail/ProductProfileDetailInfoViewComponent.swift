//
//  ProductProfileDetailInfoViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 18.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
    
    enum InfoViewModel {
        
        case message(String)
        case progress(ProductProfileDetailView.ViewModel.DateProgressViewModel)
    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct InfoView: View {
        
        let viewModel: ProductProfileDetailView.ViewModel.InfoViewModel
        
        var body: some View {

            switch viewModel {
            case let .message(message):
                VStack(alignment: .leading) {
                    
                    Text(message)
                        .multilineTextAlignment(.leading)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textPlaceholder)
                    
                    Spacer()
                    
                    Color.textPlaceholder
                        .frame(height: 0.5)
                }
                
            case let .progress(dateProgressViewModel):
                ProductProfileDetailView.DateProgressView(viewModel: dateProgressViewModel)
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailInfoViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ZStack {
            
            Color.black
            
            VStack(spacing: 40) {
                
                ProductProfileDetailView.InfoView(viewModel: .sampleMessage)
                    .frame(height: 62)
                
                ProductProfileDetailView.InfoView(viewModel: .sampleMessageShort)
                    .frame(height: 62)
                
                ProductProfileDetailView.InfoView(viewModel: .sampleProgress)
                    .frame(height: 62)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
        }.previewLayout(.fixed(width: 375, height: 350))
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.InfoViewModel {
    
    static let sampleMessage = ProductProfileDetailView.ViewModel.InfoViewModel.message("Поздравляем 🎉, Вы стали обладателем кредитной карты. Оплачивайте покупки и получайте Кешбэк и скидки от партнеров.")
    
    static let sampleMessageShort = ProductProfileDetailView.ViewModel.InfoViewModel.message("Обязательный платеж погашен!\nУ вас нет задолженности")
    
    static let sampleProgress = ProductProfileDetailView.ViewModel.InfoViewModel.progress(.sampleNormal)
    
}
