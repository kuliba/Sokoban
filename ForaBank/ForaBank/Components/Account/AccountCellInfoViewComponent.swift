//
//  AccountCellInfoViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 25.04.2022.
//

import SwiftUI

//MARK: - ViewModel

extension AccountCellInfoView {
    
    class ViewModel: AccountCellDefaultViewModel, ObservableObject {
        
        internal init(icon: Image, content: String, title: String? = nil) {
            
            super.init(id: UUID(), icon: icon, content: content, title: title)
        }
        
    }
}

//MARK: - View

struct AccountCellInfoView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(width: 40, height: 40)
                
                viewModel.icon
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                if let placeholder = viewModel.title {
                    
                    Text(verbatim: placeholder)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                }
                
                Text(verbatim: viewModel.content)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
        }
        .frame(height: 56, alignment: .leading)
    }
}

//MARK: - Preview

struct AccountCellInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            AccountCellInfoView(viewModel: .phone)
                .previewLayout(.fixed(width: 375, height: 80))
            AccountCellInfoView(viewModel: .email)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension AccountCellInfoView.ViewModel {
    
    static let phone = AccountCellInfoView.ViewModel
        .init(icon: .ic24Smartphone,
              content: "+7 898 764-87-12",
              title: "Телефон")
    
    static let email = AccountCellInfoView.ViewModel
        .init(icon: .ic24Mail,
              content: "konstan@gmail.com",
              title: "Электронная почта")
    
}
