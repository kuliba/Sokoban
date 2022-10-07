//
//  AccountCellFullButtonWithInfoViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 03.07.2022.
//

import SwiftUI

//MARK: - ViewModel
extension AccountCellFullButtonWithInfoView {
    
    class ViewModel: AccountCellDefaultViewModel, ObservableObject {
        
        let infoButton: InfoButtonViewModel
        
        let action: () -> Void
        
        internal init(id: UUID = UUID(), icon: Image, content: String, title: String? = nil, infoButton: InfoButtonViewModel, action: @escaping () -> Void) {
            self.action = action
            self.infoButton = infoButton
            super.init(id: id, icon: icon, content: content, title: title)
        }
        
        struct InfoButtonViewModel {
            
            let icon: Image
            let action: () -> Void
        }
    }
}

//MARK: - View
struct AccountCellFullButtonWithInfoView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
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
            
            Button {
                
                viewModel.infoButton.action()
                
            } label: {
                
                viewModel.infoButton.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.iconGray)
                
            }
        }
        .frame(height: 56, alignment: .leading)
        .onTapGesture {
            viewModel.action()
        }
    }
}

//MARK: - Preview

struct AccountCellFullButtonWithInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            AccountCellFullButtonWithInfoView(viewModel: .exit)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension AccountCellFullButtonWithInfoView.ViewModel {
    
    static let exit = AccountCellFullButtonWithInfoView.ViewModel
        .init(icon: .ic24LogOut,
              content: "Выход из приложения",
              title: nil,
              infoButton: .init(icon: .ic24Info, action: {}),
              action: {})
    
}
