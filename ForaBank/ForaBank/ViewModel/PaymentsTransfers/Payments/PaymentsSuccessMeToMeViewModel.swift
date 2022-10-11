//
//  PaymentsSuccessMeToMeViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI
import Combine

class PaymentsSuccessMeToMeViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    @Published var sheet: Sheet?
    
    private let model: Model
    private let state: State
    private let confirmationData: CurrencyExchangeConfirmationData
    
    var successViewModel: PaymentsSuccessViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(_ model: Model, state: State, confirmationData: CurrencyExchangeConfirmationData) {
        
        self.model = model
        self.state = state
        self.confirmationData = confirmationData
        self.successViewModel = .init(model, dismissAction: {})

        self.successViewModel = makeSuccess(model, state: state, data: confirmationData) {
            self.action.send(PaymentsSuccessMeToMeAction.Button.Close())
        }
        
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ModelAction.Payment.OperationDetailByPaymentId.Response:
                    handleDetailResponse(payload)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

extension PaymentsSuccessMeToMeViewModel {
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case printForm(PrintFormView.ViewModel)
            case detailInfo(OperationDetailInfoViewModel)
        }
    }
    
    enum State {
        
        case success(TransferResponseBaseData.DocumentStatus, Int)
        case failed(ModelError)
    }
    
    enum OptionButtonType {
        
        case template
        case document
        case details
    }
}

extension PaymentsSuccessMeToMeViewModel {

    private func makeSuccess(_ model: Model, state: State, data: CurrencyExchangeConfirmationData, closeAction: @escaping () -> Void) -> PaymentsSuccessViewModel {
        
        let amountFormatted = model.amountFormatted(amount: data.debitAmount ?? 0, currencyCode: data.currencyPayer?.description, style: .fraction)
        
        switch state {
        case let .success(status, paymentOperationDetailId):
            
            switch status {
            case .complete:
                
                return .init(model: model, iconType: .success, title: "Успешный перевод", amount: amountFormatted, optionButtons: [optionButton(.template), optionButton(.document, paymentOperationDetailId: paymentOperationDetailId), optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)], actionButton: .init(title: "На главную", style: .red) {
                    closeAction()
                })
                
            case .inProgress:
                
                return .init(model: model, iconType: .success, title: "Операция в обработке!", amount: amountFormatted, optionButtons: [optionButton(.template), optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)], actionButton: .init(title: "На главную", style: .red) {
                    closeAction()
                })
                
            case .rejected, .unknown:
                
                return .init(model: model, iconType: .success, title: "Операция неуспешна!", amount: amountFormatted, repeatButton: .init(title: "Повторить", style: .gray, action: {}), optionButtons: [optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)], actionButton: .init(title: "На главную", style: .red) {
                    closeAction()
                })
            }
            
        case .failed:
            return .sample1
        }
    }

    private func optionButton(_ type: OptionButtonType, paymentOperationDetailId: Int = 0) -> PaymentsSuccessOptionButtonView.ViewModel {
        
        switch type {
        case .template:
            return .init(icon: .ic24Star, title: "Шаблон") {}
            
        case .document:
            
            return .init(icon: .ic24File, title: "Документ") {
            
                let printViewModel: PrintFormView.ViewModel = .init(type: .operation(paymentOperationDetailId: paymentOperationDetailId, printFormType: .internal), model: self.model)
                
                self.sheet = .init(type: .printForm(printViewModel))
        }

        case .details:
            return .init(icon: .ic24Info, title: "Детали") {
                
                self.model.action.send(ModelAction.Payment.OperationDetailByPaymentId.Request(paymentOperationDetailId: paymentOperationDetailId))
            }
        }
    }
    
    private func handleDetailResponse(_ payload: ModelAction.Payment.OperationDetailByPaymentId.Response) {
        
        switch payload {
        case let .success(detailData):
            
            let viewModel: OperationDetailInfoViewModel = .init(model: model, operation: detailData) {
                self.sheet = nil
            }
            
            if sheet == nil {
                sheet = .init(type: .detailInfo(viewModel))
            }
            
        case .failture:
            break
        }
    }
}

// MARK: - Action

enum PaymentsSuccessMeToMeAction {
    
    enum Button {
        
        struct Close: Action {}
    }
}
