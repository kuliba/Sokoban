//
//  ConfirmView.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

public struct ConfirmView: View {
    
    let config: ConfirmView.Config
    @ObservedObject var viewModel: ConfirmViewModel
    let phoneNumber: String
    private var timerViewModel: ConfirmViewModel.TimerViewModel
    
    public init(
        config: ConfirmView.Config = .defaultConfig,
        viewModel: ConfirmViewModel,
        phoneNumber: String
    ) {
        self.config = config
        self.viewModel = viewModel
        self.phoneNumber = phoneNumber
        self.timerViewModel = .init(
            delay: 10,
            phoneNumber: phoneNumber,
            completeAction: { }
        )
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
                    viewModel: timerViewModel,
                    config: .defaultConfig
                )
                .padding(.top, 32)
            }
            .padding(.trailing, 20)
            .padding(.leading, 19)
            .padding(.top, 16)
            .frame(maxHeight: .infinity)
        }
        .alert(isPresented: $viewModel.showAlert) {
            .init(
                title: Text("Ошибка"),
                message: Text("Введен некорректный код.\nПопробуйте еще раз")
            )
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

