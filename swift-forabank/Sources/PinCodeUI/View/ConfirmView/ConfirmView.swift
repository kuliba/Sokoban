//
//  ConfirmView.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

public struct ConfirmView: View {
    
    let config: ConfirmView.Config
    let viewModel: ConfirmViewModel
    let phoneNumber: String
    
    public init(
        config: ConfirmView.Config = .defaultConfig,
        viewModel: ConfirmViewModel,
        phoneNumber: String
    ) {
        self.config = config
        self.viewModel = viewModel
        self.phoneNumber = phoneNumber
    }
    
    public var body: some View {
        
        HStack(alignment: .top) {
            
            VStack {
                
                Text("Введите код из сообщения")
                    .font(config.font)
                    .multilineTextAlignment(.center)
                    .foregroundColor(config.foregroundColor)
                
                PasscodeField(
                    viewModel: viewModel)
                
                TimerView(
                    viewModel: .init(
                        delay: 10,
                        phoneNumber: phoneNumber,
                        completeAction: { }),
                    config: .defaultConfig
                )
                .padding(.top, 32)
            }
            .padding(.trailing, 20)
            .padding(.leading, 19)
            .padding(.top, 16)
            .frame(maxHeight: .infinity)
        }
    }
}

struct ConfirmView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ConfirmView(
            viewModel: .defaultViewModel,
            phoneNumber: "Описание для таймера"
        )
    }
}

//MARK: - Preview Content

private extension ConfirmViewModel {
    
    static let defaultViewModel = ConfirmViewModel.init(handler: { _, _ in })
}

