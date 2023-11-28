//
//  ConfirmView.swift
//
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

public struct ConfirmView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let config: ConfirmView.Config
    @StateObject var viewModel: ConfirmViewModel
    private var timerViewModel: ConfirmViewModel.TimerViewModel
    
    public init(
        config: ConfirmView.Config = .defaultConfig,
        viewModel: ConfirmViewModel,
        resendRequest: @escaping () -> Void
    ) {
        self.config = config
        self._viewModel = .init(wrappedValue: viewModel)
        self.timerViewModel = .init(
            delay: 60,
            phoneNumber: viewModel.phoneNumber,
            completeAction: { }, 
            resendRequest: resendRequest
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
            if let buttonTitle = viewModel.infoForAllert.buttonTitle {
                if viewModel.infoForAllert.oneButton {
                    return Alert(
                        title: Text("Ошибка"),
                        message: Text(viewModel.infoForAllert.alertMessage),
                        dismissButton: Alert.Button.default(Text(buttonTitle), action: viewModel.infoForAllert.action)
                    )
                } else {
                    return Alert(
                        title: Text("Ошибка"),
                        message: Text(viewModel.infoForAllert.alertMessage),
                        primaryButton: Alert.Button.default(Text("Отмена")),
                        secondaryButton: Alert.Button.default(Text(buttonTitle), action: viewModel.infoForAllert.action)
                    )
                }
            } else {
                return Alert(
                    title: Text("Ошибка"),
                    message: Text(viewModel.infoForAllert.alertMessage)
                )
            }
        }
        .onReceive(viewModel.action) { action in
            switch action {
            case _ as ConfirmViewModelAction.Close.SelfView:
                self.presentationMode.wrappedValue.dismiss()
            default: break
            }
        }
    }
}

struct ConfirmView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ConfirmView(
            viewModel: .defaultViewModel,
            resendRequest: {}
        )
    }
}

//MARK: - Preview Content

private extension ConfirmViewModel {
    
    static let defaultViewModel = ConfirmViewModel.init(
        phoneNumber: "+1....33",
        cardId: 11111, 
        actionType: .showCvv,
        handler: { _, _ in },
        showSpinner: {},
        resendRequestAfterClose: {_,_  in })
}

