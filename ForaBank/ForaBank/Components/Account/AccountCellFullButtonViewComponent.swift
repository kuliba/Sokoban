//
//  AccountCellFullButtonViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 25.04.2022.
//

import SwiftUI

//MARK: - ViewModel
extension AccountCellFullButtonView {
    
    class ViewModel: AccountCellDefaultViewModel, ObservableObject {
        
        let action: () -> Void
        
        internal init(id: UUID = UUID(), icon: Image, content: String, title: String? = nil, action: @escaping () -> Void) {
            self.action = action
            super.init(id: id, icon: icon, content: content, title: title)
        }
    }
}

//MARK: - View
struct AccountCellFullButtonView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.action()
            
        } label: {
            
            HStack(spacing: 20) {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 40, height: 40)
                    
                    viewModel.icon
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
}

//MARK: - Preview

struct AccountCellFullButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            AccountCellFullButtonView(viewModel: .exit)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension AccountCellFullButtonView.ViewModel {
    
    static let exit = AccountCellFullButtonView.ViewModel
        .init(icon: .ic24LogOut,
              content: "Выход из приложения",
              title: nil,
              action: {})
    
}
