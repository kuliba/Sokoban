//
//  UserAccountExitInfoView.swift
//  ForaBank
//
//  Created by Mikhail on 04.07.2022.
//

import SwiftUI

extension UserAccountExitInfoView {
    
    struct ViewModel {
        
        let icon: Image
        let title: String
        let content: String
                        
        internal init(icon: Image, title: String, content: String) {
            
            self.icon = icon
            self.title = title
            self.content = content
        }
    }
}
    
extension UserAccountExitInfoView.ViewModel {
    
    static let exitInfoViewModel: UserAccountExitInfoView.ViewModel = .init(
        icon: .ic24Info,
        title: "Удаление учетной записи",
        content: "При удалении учетной записи будут удалены Ваши данные, включая персональные настройки и шаблоны по операциям.\n\nДля восстановления доступа в приложение Вам потребуется повторно пройти процедуру регистрации в «Фора-Онлайн» и выполнить необходимые настройки для использования приложения.")
}

struct UserAccountExitInfoView: View {
    
    var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 24) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 32)
                    .foregroundColor(.bGIconGrayLightest)
                    .frame(width: 64, height: 64)
                
                viewModel.icon
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.iconBlack)
            }
            
            Text(verbatim: viewModel.title)
                .font(.textH4SB16240())
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack {
                
                Text(viewModel.content)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
        }
        .padding(20)
        .padding(.bottom, 60)
    }
}

struct UserAccountExitInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountExitInfoView(viewModel: .exitInfoViewModel)
    }
}
