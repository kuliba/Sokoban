//
//  DeleteAccountView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.08.2022.
//

import SwiftUI

extension DeleteAccountView {
    
    struct DeleteAccountViewModel {
        
        //TODO: fix image after uopdate icon from figma ic88Done
        let image: Image = Image("OkOperators")
        
        let title = "Учетная запись удалена"
        let description = "Для входа в приложение потребуется\n новая регистрация данных"
        let button: ButtonSimpleView.ViewModel
        
        private var model: Model
        
        init(model: Model) {
            
            self.model = model
            self.button = .init(buttonModel: .init(title: "OK", isEnabled: true, action: { model.action.send(ModelAction.Auth.Logout()) }))
        }
    }
}

struct DeleteAccountView: View {
    
    let viewModel: DeleteAccountViewModel
    
    var body: some View {
        
        HeaderView(viewModel: viewModel)
        
        Spacer()
        
        ButtonSimpleView(viewModel: viewModel.button)
            .frame(height: 48, alignment: .center)
            .padding(.horizontal, 20)
    }
}

extension DeleteAccountView {
    
    struct HeaderView: View {
        
        let viewModel: DeleteAccountViewModel
        
        var body: some View {
            
            VStack(alignment: .center, spacing: 0) {
                
                viewModel.image
                    .frame(width: 88, height: 88)
                    .padding()
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.description)
                    .font(.textBodyMM14200())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textPlaceholder)
                    .padding()
            }
            .padding(.top, 80)
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(viewModel: .init(model: .emptyMock))
    }
}
