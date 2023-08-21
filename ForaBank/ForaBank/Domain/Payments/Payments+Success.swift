//
//  Payments+Success.swift
//  ForaBank
//
//  Created by Max Gribov on 21.03.2023.
//

import Foundation

//MARK: - Payments System

extension Payments.Success {
    
    init(
        with response: TransferResponseBaseData,
        operation: Payments.Operation,
        logoImage: SVGImageData? = nil,
        amountFormatter: (Double, ProductData.ID, Model.AmountFormatStyle) -> String?
    ) throws {
        
        guard let status = response.documentStatus else {
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.successStatus.rawValue)
        }
        
        guard let amount = operation.amount else {
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.amount.rawValue)
        }
        
        guard let productId = operation.productId else {
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.product.rawValue)
        }
        
        let amountFormatted = amountFormatter(amount, productId, .normal)
        
        let params: [PaymentsParameterRepresentable?] = [
            Payments.ParameterDataValue.operationDetail(with: response.paymentOperationDetailId),
            Payments.ParameterSuccessStatus(with: status),
            Payments.ParameterSuccessText.title(operation, documentStatus: status),
            Payments.ParameterSuccessLogo.logo(with: logoImage),
            Payments.ParameterSuccessText.amount(amount: amountFormatted),
            Payments.ParameterSuccessLogo.sfpLogo(with: operation),
            Payments.ParameterSuccessOptionButtons.buttons(
                with: .normal,
                documentStatus: status,
                operationDetail: nil,
                operation: operation,
                meToMePayment: nil
            ),
            Payments.ParameterButton.repeatButton(.normal, documentStatus: status),
            Payments.ParameterButton.actionButtonMain()
        ]
        
        self.init(
            operation: operation,
            parameters: params.compactMap{ $0 }
        )
    }
    
    init(
        with response: TransferResponseBaseData,
        operation: Payments.Operation,
        title: String? = nil
    ) throws {
        
        guard let status = response.documentStatus else {
            throw Payments.Error.missingParameter(Payments.Parameter.Identifier.successStatus.rawValue)
        }
        
        if let title {
            
            let params: [PaymentsParameterRepresentable?] = [
                Payments.ParameterDataValue.operationDetail(with: response.paymentOperationDetailId),
                Payments.ParameterSuccessStatus(with: status),
                Payments.ParameterSuccessText.title(with: title),
                Payments.ParameterSuccessOptionButtons.buttons(
                    with: .normal,
                    documentStatus: status,
                    operation: operation,
                    meToMePayment: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]
            
            self.init(
                operation: operation,
                parameters: params.compactMap{ $0 }
            )
            
        } else {
            
            let params: [PaymentsParameterRepresentable?] = [
                Payments.ParameterDataValue.operationDetail(with: response.paymentOperationDetailId),
                Payments.ParameterSuccessStatus(with: status),
                Payments.ParameterSuccessText.title(.normal, documentStatus: status),
                Payments.ParameterSuccessOptionButtons.buttons(
                    with: .normal,
                    documentStatus: status,
                    operationDetail: nil,
                    operation: operation,
                    meToMePayment: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]
            
            self.init(
                operation: operation,
                parameters: params.compactMap{ $0 }
            )
        }
    }
}

//MARK: - Mode

extension Payments.Success {
    
    init?(
        model: Model,
        mode: PaymentsSuccessViewModel.Mode,
        amountFormatter: (Double, String?, Model.AmountFormatStyle) -> String?
    ) {
        
        switch mode {
        case let .meToMe(from: _, to: _, transferData):
            guard let documentStatus = transferData.documentStatus else {
                return nil
            }
            
            let debitAmount = transferData.debitAmount ?? 0
            let currencyCode = transferData.currencyPayer?.description
            let amountFormatted = amountFormatter(debitAmount, currencyCode, .fraction)
            
            self.init(
                model: model,
                mode: mode,
                paymentOperationDetailId: transferData.paymentOperationDetailId,
                documentStatus: documentStatus,
                amount: amountFormatted
            )
            
        case let .makePaymentToDeposit(from: _, to: _, transferData):
            guard let documentStatus = transferData.documentStatus else {
                return nil
            }
            
            let debitAmount = transferData.debitAmount ?? 0
            let currencyCode = transferData.currencyPayer?.description
            let amountFormatted = amountFormatter(debitAmount, currencyCode, .fraction)
            
            self.init(
                model: model,
                mode: mode,
                paymentOperationDetailId: transferData.paymentOperationDetailId,
                documentStatus: documentStatus,
                amount: amountFormatted)
            
        case let .makePaymentFromDeposit(from: _, to: _, transferData):
            guard let documentStatus = transferData.documentStatus else {
                return nil
            }
            
            let debitAmount = transferData.debitAmount ?? 0
            let currencyCode = transferData.currencyPayer?.description
            let amountFormatted = amountFormatter(debitAmount, currencyCode, .fraction)
            
            self.init(
                model: model,
                mode: mode,
                paymentOperationDetailId: transferData.paymentOperationDetailId,
                documentStatus: documentStatus,
                amount: amountFormatted)
            
        case let .closeAccount(_, currency, balance: balance, transferData):
            let amount = amountFormatter(balance, currency.description, .fraction)
            
            self.init(
                model: model,
                mode: mode,
                paymentOperationDetailId: transferData.paymentOperationDetailId,
                documentStatus: transferData.documentStatus,
                amount: amount)
            
        case let .closeAccountEmpty(_, currency, balance: balance, transferData):
            let amount = amountFormatter(balance, currency.description, .fraction)
            
            self.init(
                model: model,
                mode: mode,
                paymentOperationDetailId: transferData.paymentOperationDetailId,
                documentStatus: transferData.documentStatus,
                amount: amount)
            
        case let .closeDeposit(currency, balance: balance, transferData):
            let amount = amountFormatter(balance, currency.description, .fraction)
            
            self.init(
                model: model,
                mode: mode,
                paymentOperationDetailId: transferData.paymentOperationDetailId,
                documentStatus: transferData.documentStatus,
                amount: amount)
            
        default:
            return nil
        }
    }
    
    init(
        model: Model,
        mode: PaymentsSuccessViewModel.Mode,
        paymentOperationDetailId: Int?,
        documentStatus: TransferResponseBaseData.DocumentStatus,
        amount: String?
    ) {
        
        let params: [PaymentsParameterRepresentable?] = [
            Payments.ParameterSuccessMode(mode: mode),
            Payments.ParameterDataValue.operationDetail(with: paymentOperationDetailId),
            Payments.ParameterSuccessStatus(with: documentStatus),
            Payments.ParameterSuccessText.title(mode, documentStatus: documentStatus),
            Payments.ParameterSuccessText.amount(amount: amount),
            Payments.ParameterSuccessOptionButtons.buttons(
                with: mode,
                documentStatus: documentStatus,
                operation: nil,
                meToMePayment: nil
            ),
            Payments.ParameterButton.repeatButton(mode, documentStatus: documentStatus),
            Payments.ParameterButton.actionButtonMain()
        ]
        
        self.init(
            operation: nil,
            parameters: params.compactMap { $0 }
        )
    }
}

//MARK: - C2B

extension Payments.Success {
    
    init(with subscriptionData: C2BSubscriptionData) {
        
        let params: [PaymentsParameterRepresentable?] = [
            Payments.ParameterSuccessStatus(with: subscriptionData.operationStatus),
            Payments.ParameterSuccessText(value: subscriptionData.title, style: .title),
            Payments.ParameterSubscriber(with: subscriptionData),
            Payments.ParameterSuccessLink(with: subscriptionData),
            Payments.ParameterButton.actionButtonMain(),
            Payments.ParameterSuccessIcon(icon: .name("ic72Sbp"), size: .normal, placement: .bottom)
        ]
        
        self.init(
            operation: nil,
            parameters: params.compactMap { $0 }
        )
    }
}

//MARK: - Helpers

extension Payments.Success {
    
    var status: TransferResponseBaseData.DocumentStatus? {
        
        guard let param = try? parameters.parameter(forIdentifier: .successStatus, as: Payments.ParameterSuccessStatus.self) else {
            return nil
        }
        
        return param.documentStatus
    }
    
    static func parameters(
        with operationDetail: OperationDetailData,
        amountFormatter: (Double, String, Model.AmountFormatStyle) -> String?,
        mode: PaymentsSuccessViewModel.Mode,
        documentStatus: TransferResponseBaseData.DocumentStatus,
        operation: Payments.Operation?
    ) -> (parameters: [PaymentsParameterRepresentable], transferType: OperationDetailData.TransferEnum)? {
        
        guard let transferType = operationDetail.transferEnum else { return nil }
        
        var parameters = [PaymentsParameterRepresentable?]()
        
        switch transferType {
        case .direct:
            // logo
            //TODO: load image from the style guide
            let logoParam = Payments.ParameterSuccessLogo(icon: .name("MigAvatar"))
            parameters.append(logoParam)
            
            // amount
            let amount = amountFormatter(operationDetail.amount, operationDetail.currencyAmount, .fraction)
            let amountParam = Payments.ParameterSuccessText.amount(amount: amount)
            parameters.append(amountParam)
            
        case .changeOutgoing, .returnOutgoing:
            // logo
            //TODO: load image from the style guide
            let logoParam = Payments.ParameterSuccessLogo(icon: .name("Operation Type Contact Icon"))
            parameters.append(logoParam)
            
            // amount
            let amount = amountFormatter(operationDetail.payerAmount, operationDetail.currencyAmount, .fraction)
            let amountParam = Payments.ParameterSuccessText.amount(amount: amount)
            parameters.append(amountParam)
            
        case .contactAddressing, .contactAddressless, .contactAddressingCash:
            // logo
            //TODO: load image from the style guide
            let logoParam = Payments.ParameterSuccessLogo(icon: .name("Operation Type Contact Icon"))
            parameters.append(logoParam)
            
            // amount
            if let payeeAmount = operationDetail.payeeAmount {
                
                let amount = amountFormatter(payeeAmount, operationDetail.currencyAmount, .fraction)
                let amountParam = Payments.ParameterSuccessText.amount(amount: amount)
                parameters.append(amountParam)
            }
            
            // transfer number
            if let transferNumber = operationDetail.transferReference {
                
                let transferNumberParam = Payments.ParameterSuccessTransferNumber(number: transferNumber)
                parameters.append(transferNumberParam)
            }
            
            // additional buttons
            let additionalButtonsOptions: [Payments.ParameterSuccessAdditionalButtons.Option] = operationDetail.payeeFullName != nil ? [.change, .return] : [.return]
            let additionalButtonsParam = Payments.ParameterSuccessAdditionalButtons(options: additionalButtonsOptions)
            parameters.append(additionalButtonsParam)
            
        default:
            break
        }
        
        // options buttons
        let optionButtonsParam = Payments.ParameterSuccessOptionButtons.buttons(
            with: mode,
            documentStatus: documentStatus,
            operationDetail: operationDetail,
            operation: operation,
            meToMePayment: nil
        )
        parameters.append(optionButtonsParam)
        
        return (parameters.compactMap { $0 }, transferType)
    }
}

//MARK: - Parameters Extensions

extension Payments.ParameterSuccessText {
    
    static func title(_ mode: PaymentsSuccessViewModel.Mode, documentStatus: TransferResponseBaseData.DocumentStatus) -> Payments.ParameterSuccessText? {
        
        let paramId = Payments.Parameter.Identifier.successTitle.rawValue
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .normal, .meToMe, .closeDeposit, .closeAccount, .makePaymentToDeposit, .makePaymentFromDeposit:
                return .init(id: paramId, value: "Успешный перевод", style: .title)
                
            case .closeAccountEmpty:
                return .init(id: paramId, value: "Счет успешно закрыт", style: .title)
            }
            
        case .inProgress:
            
            switch mode {
            case .normal, .meToMe:
                return .init(id: paramId, value: "Операция в обработке!", style: .title)
                
            case .closeAccount, .closeDeposit, .closeAccountEmpty, .makePaymentToDeposit, .makePaymentFromDeposit:
                return .init(id: paramId, value: "Платеж принят в обработку", style: .title)
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .meToMe, .makePaymentToDeposit, .makePaymentFromDeposit:
                return .init(id: paramId, value: "Операция неуспешна!", style: .title)
                
            case .closeAccountEmpty, .closeDeposit, .closeAccount:
                return .init(id: paramId, value: "Отказ", style: .title)
            }
        }
    }
    
    static func title(_ operation: Payments.Operation, documentStatus: TransferResponseBaseData.DocumentStatus) -> Payments.ParameterSuccessText? {
        
        let paramId = Payments.Parameter.Identifier.successTitle.rawValue
        
        if let _ = operation.source {
            
            switch documentStatus {
            case .complete:
                return .init(id: paramId, value: "Успешный перевод", style: .title)
                
            case .inProgress:
                return .init(id: paramId, value: "Операция в обработке!", style: .title)
                
            case .rejected, .unknown:
                switch operation.source {
                case .sfp:
                    return .init(id: paramId, value: "Отказ", style: .title)
                    
                default:
                    return .init(id: paramId, value: "Операция неуспешна!", style: .title)
                }
            }
            
        } else {
            
            switch documentStatus {
            case .complete:
                return .init(id: paramId, value: "Успешный перевод", style: .title)
                
            case .inProgress:
                return .init(id: paramId, value: "Операция в обработке!", style: .title)
                
            case .rejected, .unknown:
                switch operation.service {
                case .sfp:
                    return .init(id: paramId, value: "Отказ", style: .title)
                    
                default:
                    return .init(id: paramId, value: "Операция неуспешна!", style: .title)
                }
            }
        }
    }
    
    static func title(with text: String) -> Payments.ParameterSuccessText? {
        
        .init(id: Payments.Parameter.Identifier.successTitle.rawValue, value: text, style: .title)
    }
    
    static func amount(amount: String?) -> Payments.ParameterSuccessText? {
        
        guard let amount else { return nil }
        
        return .init(id: Payments.Parameter.Identifier.successAmount.rawValue, value: amount, style: .amount)
    }
}

extension Payments.ParameterSuccessOptionButtons {
    
    static func buttons(
        with mode: PaymentsSuccessViewModel.Mode,
        documentStatus: TransferResponseBaseData.DocumentStatus,
        operationDetail: OperationDetailData? = nil,
        operation: Payments.Operation?,
        meToMePayment: MeToMePayment?
    ) -> Payments.ParameterSuccessOptionButtons? {
        
        switch documentStatus {
        case .complete:
            
            return completeOptionButtons(
                mode,
                operation,
                operationDetail,
                meToMePayment
            )
            
        case .inProgress:
            
            return progressOptionButtons(
                mode,
                operation,
                operationDetail,
                meToMePayment
            )
            
        case .rejected, .unknown:
            
            return rejectedOptionButtons(
                mode,
                meToMePayment,
                operation
            )
        }
    }
    
    private static func completeOptionButtons(
        _ mode: PaymentsSuccessViewModel.Mode,
        _ operation: Payments.Operation?,
        _ operationDetail: OperationDetailData?,
        _ meToMePayment: MeToMePayment?
    ) -> Payments.ParameterSuccessOptionButtons? {
        
        switch mode {
        case .normal, .meToMe:
            return optionButtons(
                operation: operation,
                options: [.template, .document, .details],
                operationDetail: operationDetail,
                meToMePayment: meToMePayment
            )
            
        case .closeAccount:
            return .init(
                options: [.document, operationDetail.map { _ in .details }].compactMap { $0 },
                operationDetail: operationDetail,
                templateID: nil,
                meToMePayment: meToMePayment,
                operation: operation
            )
            
        case .makePaymentToDeposit, .makePaymentFromDeposit, .closeDeposit:
            return .init(
                options: [.document, .details],
                templateID: nil,
                meToMePayment: meToMePayment,
                operation: operation
            )
            
        case .closeAccountEmpty:
            return .init(
                options: [.document],
                templateID: nil,
                meToMePayment: meToMePayment,
                operation: operation
            )
        }
    }
    
    private static func progressOptionButtons(
        _ mode: PaymentsSuccessViewModel.Mode,
        _ operation: Payments.Operation?,
        _ operationDetail: OperationDetailData?,
        _ meToMePayment: MeToMePayment?
    ) -> Payments.ParameterSuccessOptionButtons? {
        
        switch mode {
        case .normal, .meToMe:
            return optionButtons(
                operation: operation,
                options: [.template, .details],
                operationDetail: operationDetail,
                meToMePayment: meToMePayment
            )
            
        case .makePaymentToDeposit, .makePaymentFromDeposit, .closeDeposit:
            return .init(
                options: [.details],
                templateID: nil,
                meToMePayment: meToMePayment,
                operation: operation
            )
            
        case .closeAccount, .closeAccountEmpty:
            return nil
        }
    }
    
    private static func rejectedOptionButtons(
        _ mode: PaymentsSuccessViewModel.Mode,
        _ meToMePayment: MeToMePayment?,
        _ operation: Payments.Operation?
    ) -> Payments.ParameterSuccessOptionButtons? {
        
        switch mode {
        case .normal, .meToMe, .makePaymentToDeposit, .makePaymentFromDeposit, .closeDeposit:
            return .init(
                options: [.details],
                templateID: nil,
                meToMePayment: meToMePayment,
                operation: operation
            )
            
        default:
            return nil
        }
    }
    
    private static func optionButtons(
        operation: Payments.Operation?,
        options: [Payments.ParameterSuccessOptionButtons.Option],
        operationDetail: OperationDetailData?,
        meToMePayment: MeToMePayment?
    ) -> Payments.ParameterSuccessOptionButtons {
        
        switch operation?.source {
        case let .template(templateID):
            return .init(
                options: options,
                operationDetail: operationDetail,
                templateID: templateID,
                meToMePayment: meToMePayment,
                operation: operation
            )
        default:
            
            return .init(
                options: options,
                operationDetail: operationDetail,
                templateID: nil,
                meToMePayment: meToMePayment,
                operation: operation
            )
        }
    }
}

extension Payments.ParameterButton {
    
    static func repeatButton(_ mode: PaymentsSuccessViewModel.Mode, documentStatus: TransferResponseBaseData.DocumentStatus) -> Payments.ParameterButton? {
        
        let paramId = Payments.Parameter.Identifier.successRepeatButton.rawValue
        
        switch documentStatus {
        case .complete:
            return nil
            
        case .inProgress:
            return nil
            
        case .rejected, .unknown:
            switch mode {
            case .makePaymentToDeposit, .closeDeposit:
                return nil
                
            default:
                return .init(parameterId: paramId, title: "Повторить", style: .secondary, acton: .repeat, placement: .bottom)
            }
        }
    }
    
    static func actionButtonMain() -> Payments.ParameterButton {
        
        .init(parameterId: Payments.Parameter.Identifier.successActionButton.rawValue, title: "На главный", style: .primary, acton: .main, placement: .bottom)
    }
}

extension Payments.ParameterDataValue {
    
    static func operationDetail(with paymentOperationDetailId: Int?) -> Payments.ParameterDataValue? {
        
        guard let paymentOperationDetailId else {
            return nil
        }
        
        return .init(parameter: .init(id: Payments.Parameter.Identifier.successOperationDetailID.rawValue, value: paymentOperationDetailId.description))
    }
}

extension Payments.ParameterSuccessLogo {
    
    static func logo(with svgImage: SVGImageData?) -> Payments.ParameterSuccessLogo? {
        
        guard let svgImage, let imageData = ImageData(with: svgImage) else { return nil }
        
        return .init(icon: .image(imageData))
    }
    
    static func sfpLogo(with operation: Payments.Operation) -> Payments.ParameterSuccessLogo? {
        
        guard case .sfp(_, _) = operation.source else { return nil }
        
        // this is super ugly workaround. Durring sfp payment user may execute internal bank transfer (if he choose Fora Bank as a distination, and his own phone number). Ideally our backend have to give us this info in response, but now it's don't.
        // so this solution based on the fact: for intenal payment first step on back must be .remote(.confirm), in other case this is sfp operation
        guard operation.steps.first?.back.stage == .remote(.start) else { return nil }
        
        return .init(icon: .sfp)
    }
}

extension Payments.ParameterSuccessStatus {
    
    var documentStatus: TransferResponseBaseData.DocumentStatus {
        
        switch status {
        case .success:
            return .complete
            
        case .accepted:
            return .inProgress
            
        case .error:
            return .rejected
            
        case .transfer:
            return .unknown
        }
    }
}
