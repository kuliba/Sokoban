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
    private let mode: Mode
    private let state: State
    private let responseData: TransferResponseData
    
    var successViewModel: PaymentsSuccessViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(_ model: Model, mode: Mode, state: State, responseData: TransferResponseData) {
        
        self.model = model
        self.mode = mode
        self.state = state
        self.responseData = responseData
        self.successViewModel = .init(model, dismissAction: {})

        self.successViewModel = makeSuccess(model, state: state, data: responseData, repeatAction: { [weak self] in
            self?.action.send(PaymentsSuccessMeToMeAction.Button.Repeat())
        }, closeAction: { [weak self] in
            self?.action.send(PaymentsSuccessMeToMeAction.Button.Close())
        })
        
        bind()
    }

    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ModelAction.Payment.OperationDetailByPaymentId.Response:
                    handleDetailResponse(payload)
                    
                case let payload as ModelAction.PaymentTemplate.Save.Complete:

                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон", isSelected: true) { [weak self] in

                        self?.model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [payload.paymentTemplateId]))
                    }

                    successViewModel.optionButtons[0] = templateButton

                case _ as ModelAction.PaymentTemplate.Delete.Complete:

                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон") { [weak self] in

                        guard let self = self else { return }

                        switch self.state {
                        case let .success(_, paymentOperationDetailId):

                            self.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId))

                        case .failed:
                            break
                        }
                    }

                    successViewModel.optionButtons[0] = templateButton
                    
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
    
    enum Mode {
        
        case meToMe
        case closeAccount
        case closeAccountEmpty(ProductData.ID)
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
    
    private func title(documentStatus: TransferResponseBaseData.DocumentStatus) -> String {
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .meToMe, .closeAccount: return "Успешный перевод"
            case .closeAccountEmpty: return "Счет успешно закрыт"
            }
            
        case .inProgress:
            
            switch mode {
            case .meToMe: return "Операция в обработке!"
            case .closeAccount, .closeAccountEmpty: return .init()
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .meToMe: return "Операция неуспешна!"
            case .closeAccount: return .init()
            case .closeAccountEmpty: return "Отказ"
            }
        }
    }
    
    private func makeOptionButtons(_ documentStatus: TransferResponseBaseData.DocumentStatus, paymentOperationDetailId: Int) -> [PaymentsSuccessOptionButtonViewModel] {
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .meToMe:
                
                return [optionButton(.template, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.document, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeAccount:
                
                return [optionButton(.document, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeAccountEmpty:
                
                return [optionButton(.document, paymentOperationDetailId: paymentOperationDetailId)]
            }
            
        case .inProgress:
            
            switch mode {
            case .meToMe:
                
                return [optionButton(.template, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeAccount, .closeAccountEmpty:
                return .init()
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .meToMe:
                
                return [optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeAccount, .closeAccountEmpty:
                return .init()
            }
        }
    }

    private func makeSuccess(_ model: Model, state: State, data: TransferResponseData, repeatAction: @escaping () -> Void, closeAction: @escaping () -> Void) -> PaymentsSuccessViewModel {
        
        let amountFormatted = model.amountFormatted(amount: data.debitAmount ?? 0, currencyCode: data.currencyPayer?.description, style: .fraction)
        
        let amount = data.debitAmount == 0 ? nil : amountFormatted
        
        switch state {
        case let .success(status, paymentOperationDetailId):
            
            let title = title(documentStatus: status)
            let optionButtons = makeOptionButtons(status, paymentOperationDetailId: paymentOperationDetailId)
            
            switch status {
            case .complete:
                
                return .init(model: model, iconType: .success, title: title, amount: amount, optionButtons: optionButtons, actionButton: .init(title: "На главную", style: .red, action: closeAction))
                
            case .inProgress:
                
                return .init(model: model, iconType: .accepted, title: title, amount: amount, optionButtons: optionButtons, actionButton: .init(title: "На главную", style: .red, action: closeAction))
                
            case .rejected, .unknown:
                
                return .init(model: model, iconType: .error, title: title, amount: amount, repeatButton: .init(title: "Повторить", style: .gray, action: repeatAction), optionButtons: optionButtons, actionButton: .init(title: "На главную", style: .red, action: closeAction))
            }
            
        case .failed:

            return .init(model: model, iconType: .error, title: "Операция неуспешна!", amount: amountFormatted, repeatButton: .init(title: "Повторить", style: .gray, action: repeatAction), optionButtons: [optionButton(.details, paymentOperationDetailId: data.paymentOperationDetailId)], actionButton: .init(title: "На главную", style: .red, action: closeAction))
        }
    }

    private func optionButton(_ type: OptionButtonType, paymentOperationDetailId: Int = 0) -> PaymentsSuccessOptionButtonView.ViewModel {
        
        switch type {
        case .template:
            
            return .init(icon: .ic24Star, title: "Шаблон") { [weak self] in
                
                self?.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId))
            }
            
        case .document:
            
            return .init(icon: .ic24File, title: "Документ") { [weak self] in
                
                guard let self = self else {
                    return
                }
            
                switch self.mode {
                case .meToMe, .closeAccount:
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .operation(paymentOperationDetailId: paymentOperationDetailId, printFormType: .internal), model: self.model)
                    
                    self.sheet = .init(type: .printForm(printViewModel))
                    
                case let .closeAccountEmpty(productId):
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .closeAccount(id: productId), model: self.model)
                    
                    self.sheet = .init(type: .printForm(printViewModel))
                }
        }

        case .details:
            return .init(icon: .ic24Info, title: "Детали") { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                self.model.action.send(ModelAction.Payment.OperationDetailByPaymentId.Request(paymentOperationDetailId: paymentOperationDetailId))
            }
        }
    }
    
    private func handleDetailResponse(_ payload: ModelAction.Payment.OperationDetailByPaymentId.Response) {
        
        switch payload {
        case let .success(detailData):
            
            let viewModel: OperationDetailInfoViewModel = .init(model: model, operation: detailData) { [weak self] in
                
                guard let self = self else {
                    return
                }
                
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
        struct Repeat: Action {}
    }
    
    enum OptionButton {
        
        enum Template {
            
            struct Tap: Action {}
        }
        
        enum Document {
            
            struct Tap: Action {}
        }
        
        enum details {
            
            struct Tap: Action {}
        }
    }
}
