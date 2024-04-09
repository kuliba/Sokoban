//
//  Model+PaymentsC2B.swift
//  ForaBank
//
//  Created by Max Gribov on 02.02.2023.
//

import Foundation
import ServerAgent

extension Model {
        
    internal func c2BParameters(
        data: QRScenarioData,
        parameters: [PaymentsParameterRepresentable],
        visible: [Payments.Operation.Step.Parameter.ID]
    ) throws -> (parameters: [PaymentsParameterRepresentable], visible: [Payments.Operation.Step.Parameter.ID]) {
        
        var parameters = [PaymentsParameterRepresentable]()
        var visible = [Payments.Operation.Step.Parameter.ID]()
        
        parameters.append(contentsOf: try self.paymentsC2BReduceScenarioData(
            data: data.parameters,
            c2b: .default
        ))
        
        visible = parameters.map { $0.id }
        
        parameters.append(Payments.ParameterDataValue(
            parameter: .init(
                id: Payments.Parameter.Identifier.c2bQrcId.rawValue,
                value: data.qrcId
            )
        ))
        
        if let amount = parameters.first(where: { $0.id == Payments.Parameter.Identifier.amount.rawValue }),
           amount.value == nil {
            
            parameters.append(Payments.ParameterDataValue(parameter: .init(
                id: Payments.Parameter.Identifier.c2bIsAmountComplete.rawValue,
                value: "false"
            )))
        }
        
        return (parameters, visible)
    }
    
    func paymentsStepC2B(
        _ operation: Payments.Operation,
        for stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            guard let source = operation.source else {
                throw Payments.Error.missingSource(.c2b)
            }
            
            switch source {
            case let .c2b(url):
                
                let qrLink = QRLink(link: .init(url.absoluteString))
                let parameters = try await paymentsStepC2B(by: qrLink)
                
                let required: [Payments.Parameter.ID] = [
                    Payments.Parameter.Identifier.product.rawValue,
                    Payments.Parameter.Identifier.c2bQrcId.rawValue
                ]
                
                return .init(
                    parameters: parameters.parameters,
                    front: .init(
                        visible: parameters.visible,
                        isCompleted: false),
                    back: .init(
                        stage: .remote(.complete),
                        required: required,
                        processed: nil))
                
            case let .c2bSubscribe(url):
                
                let qrLink = QRLink(link: .init(url.absoluteString))
                let response = try await paymentsStepC2BSubscribe(by: qrLink)
                
                var parameters = [PaymentsParameterRepresentable]()
                
                //FIXME: rewrite all this. Real buttons parameters must be used instead of ParameterSubscribe.
                // response parameters
                let responseParameters = try paymentsC2BReduceScenarioData(data: response.parameters, c2b: .default)
                    .filter({ ["button_save", "button_cancel", "sfp_logo"].contains($0.id) == false })
                
                parameters.append(contentsOf: responseParameters)
                
                // subscribe
                let precondition = response.parameters.precondition
                
                let subscribeParameter = Payments.ParameterSubscribe(
                    buttons: [
                        .init(title: "Привязать счет", style: .primary, action: .confirm, precondition: precondition),
                        .init(title: "Пока нет", style: .secondary, action: .deny, precondition: nil)
                    ],
                    icon: "ic72Sbp"
                )
                parameters.append(subscribeParameter)
                
                let visible = parameters.map(\.id)
                
                parameters.append(Payments.ParameterDataValue(parameter: .init(id: Payments.Parameter.Identifier.c2bQrcId.rawValue, value: response.qrcId)))
                
                return .init(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .remote(.complete), required: [Payments.Parameter.Identifier.product.rawValue], processed: nil))
                
            default:
                throw Payments.Error.unsupported
            }
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsC2BComplete(operation: Payments.Operation) async throws -> Payments.Success {
        
        guard let source = operation.source else {
            throw Payments.Error.missingSource(.c2b)
        }
        
        switch source {
        case .c2b:
            guard let token = token else {
                throw Payments.Error.notAuthorized
            }
            
            let qrcIdParamId = Payments.Parameter.Identifier.c2bQrcId.rawValue
            guard let qrcParamValue = operation.parameters.first(where: { $0.id == qrcIdParamId })?.value else {
                throw Payments.Error.missingParameter(qrcIdParamId)
            }
            
            let productParamId = Payments.Parameter.Identifier.product.rawValue
            guard let productParam = operation.parameters.first(where: { $0.id == productParamId }) else {
                throw Payments.Error.missingParameter(productParamId)
            }
            
            guard let productIdString = productParam.value,
                  let productId = Int(productIdString),
                  let product = product(productId: productId) else {
                throw Payments.Error.missingValueForParameter(productParamId)
            }
            
            let parameters = getC2bPayloadParameters(qrcParamValue, operation, product)
            
            switch product {
            case _ as ProductCardData:
                let command = ServerCommands.SBPPaymentController.CreateC2BPaymentCard(token: token, payload: .init(parameters: parameters))
                let result = try await serverAgent.executeCommand(command: command)
                var resultParameters = try paymentsC2BReduceScenarioData(data: result.parameters, c2b: .default)
                resultParameters.append(Payments.ParameterDataValue(parameter: .init(id: qrcIdParamId, value: qrcParamValue)))
                
                return .init(
                    operation: operation,
                    parameters: resultParameters
                )
                
            case _ as ProductAccountData:
                let command = ServerCommands.SBPPaymentController.CreateC2BPaymentAcc(token: token, payload: .init(parameters: parameters))
                let result = try await serverAgent.executeCommand(command: command)
                var resultParameters = try paymentsC2BReduceScenarioData(data: result.parameters, c2b: .default)
                resultParameters.append(Payments.ParameterDataValue(parameter: .init(id: qrcIdParamId, value: qrcParamValue)))
                
                return .init(
                    operation: operation,
                    parameters: resultParameters
                )
                
            default:
                throw Payments.Error.unexpectedProductType(product.productType)
            }
            
        case .c2bSubscribe:
            
            let subscribeParamId = Payments.Parameter.Identifier.subscribe.rawValue
            guard let subscribeParam = operation.parameters.first(where: { $0.id == Payments.Parameter.Identifier.subscribe.rawValue }) else {
                throw Payments.Error.missingParameter(subscribeParamId)
            }
            
            guard let subscribeValue = subscribeParam.value,
                  let actionType = Payments.ParameterSubscribe.Button.Action(rawValue: subscribeValue) else {
                throw Payments.Error.missingValueForParameter(subscribeParamId)
            }
            
            switch actionType {
            case .confirm:
                return try await paymentsC2BSubscribe(parameters: operation.parameters)
                
            case .deny:
                return try await paymentsC2BDeny(parameters: operation.parameters)
            }
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    internal func getC2bPayloadParameters(
        _ c2bId: String,
        _ operation: Payments.Operation,
        _ product: ProductData
    ) -> [PaymentC2BParameter] {
        
        var parameters = [PaymentC2BParameter]()
        
        parameters.append(.init(id: Payments.Parameter.Identifier.c2bQrcId.rawValue, value: c2bId))
        parameters.append(.init(id: "debit_account", value: product.id.description))
        
        let amount = Payments.Parameter.Identifier.amount.rawValue
        if let amount = try? operation.parameters.parameter(forId: amount, as: Payments.ParameterAmount.self),
           let amountComplete = try? operation.parameters.value(forIdentifier: .c2bIsAmountComplete),
           amountComplete == "false",
           let amountValue = amount.value {
            
            parameters.append(.init(id: "payment_amount", value: amountValue))
            parameters.append(.init(id: "currency", value: product.currency))
        }
        
        return parameters
    }
    
    func paymentsC2BSubscribe(parameters: [PaymentsParameterRepresentable]) async throws -> Payments.Success {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let qrcIdParamId = Payments.Parameter.Identifier.c2bQrcId.rawValue
        guard let qrcParam = parameters.first(where: { $0.id == qrcIdParamId }) else {
            throw Payments.Error.missingParameter(qrcIdParamId)
        }
        
        guard let qrcIdParamValue = qrcParam.value else {
            throw Payments.Error.missingValueForParameter(qrcIdParamId)
        }
        
        let productParamId = Payments.Parameter.Identifier.product.rawValue
        guard let productParam = parameters.first(where: { $0.id == productParamId }) else {
            throw Payments.Error.missingParameter(productParamId)
        }
        
        guard let productIdString = productParam.value,
              let productId = Int(productIdString),
              let product = product(productId: productId) else {
            throw Payments.Error.missingValueForParameter(productParamId)
        }
        
        switch product {
        case let card as ProductCardData:
            let command = ServerCommands.SubscriptionController.ConfirmC2BSubCard(token: token, payload: .init(qrcId: qrcIdParamValue, productId: String(card.id)))
            let result = try await serverAgent.executeCommand(command: command)
            
            return .init(with: result)
            
        case let account as ProductAccountData:
            let command = ServerCommands.SubscriptionController.ConfirmC2BSubAcc(token: token, payload: .init(qrcId: qrcIdParamValue, productId: String(account.id)))
            let result = try await serverAgent.executeCommand(command: command)
            
            return .init(with: result)
            
        default:
            throw Payments.Error.unexpectedProductType(product.productType)
        }
    }
    
    func paymentsC2BDeny(parameters: [PaymentsParameterRepresentable]) async throws -> Payments.Success {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let qrcIdParamId = Payments.Parameter.Identifier.c2bQrcId.rawValue
        guard let qrcParam = parameters.first(where: { $0.id == qrcIdParamId }) else {
            throw Payments.Error.missingParameter(qrcIdParamId)
        }
        
        guard let qrcIdParamValue = qrcParam.value else {
            throw Payments.Error.missingValueForParameter(qrcIdParamId)
        }
        
        let command = ServerCommands.SubscriptionController.DeniedC2BSubscription(token: token, payload: .init(qrcId: qrcIdParamValue))
        let result = try await serverAgent.executeCommand(command: command)
        
        return .init(with: result)
    }
    
    func paymentsC2BActionSubscribe<Command: ServerCommand>(
        makeCommand: @escaping (String) throws -> Command,
        parameters: [PaymentsParameterRepresentable]
    ) async throws -> Payments.Success {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let command = try makeCommand(token)
        guard let result = try await serverAgent.executeCommand(command: command) as? C2BSubscriptionData else {
            throw ServerAgentError.emptyResponseData
        }

        return .init(with: result)
    }
    
    enum C2B {
        
        case `default`
        case success
    }
    
    func paymentsC2BReduceScenarioData(
        data: [AnyPaymentParameter],
        c2b: C2B
    ) throws -> [PaymentsParameterRepresentable] {
        
        var parameters = [PaymentsParameterRepresentable]()
        
        for parameterData in data {
            
            switch parameterData.parameter {
            case let header as PaymentParameterHeader:
                parameters.append(Payments.ParameterHeader(title: header.value, subtitle: nil, icon: nil, rightButton: []))
                
            case let subscriber as PaymentParameterSubscriber:
                parameters.append(Payments.ParameterSubscriber(
                    .init(id: subscriber.id, value: subscriber.value),
                    icon: subscriber.icon,
                    description: subscriber.description
                ))
                
            case let productSelect as PaymentParameterProductSelect:
                if let productSelectValue = productSelect.value,
                    let productId = Int(productSelectValue) {
                    
                    guard let product = product(productId: productId) else {
                        throw Payments.Error.missingValueForParameter(productSelect.id)
                    }
                    
                    parameters.append(Payments.ParameterProduct(with: productSelect, product: product))
                    
                } else {
                    
                    parameters.append(try Payments.ParameterProduct(with: productSelect, firstProduct: { filter in firstProduct(with: filter)}))
                }
                
            case let check as PaymentParameterCheck:
                parameters.append(Payments.ParameterCheck(with: check))
                
            case let button as PaymentParameterButton:
                
                switch c2b {
                case .default:
                    parameters.append(Payments.ParameterButton(with: button))

                case .success:
                    
                    switch button.action {
                    case .cancel:
                        parameters.append(
                            Payments.ParameterButton(with: .init(
                                id: button.id,
                                value: button.value,
                                color: button.color,
                                action: .cancelSubscribe,
                                placement: button.placement
                            ))
                        )
                    case .save:
                        parameters.append(
                            Payments.ParameterButton(with: .init(
                                id: button.id,
                                value: button.value,
                                color: button.color,
                                action: .update,
                                placement: button.placement
                            ))
                        )
                    default:
                        break
                    }
                }
                
            case let info as PaymentParameterInfo:
                parameters.append(Payments.ParameterInfo(with: info))
                
            case let status as PaymentParameterStatus:
                parameters.append(Payments.ParameterSuccessStatus(with: status))
                
            case let text as PaymentParameterText:
                parameters.append(Payments.ParameterSuccessText(with: text))
                
            case let optionButtons as PaymentParameterOptionButtons:
                parameters.append(Payments.ParameterSuccessOptionButtons(
                    with: optionButtons,
                    templateID: nil,
                    operation: nil,
                    meToMePayment: nil
                ))
                
            case let icon as PaymentParameterIcon:
                parameters.append(Payments.ParameterSuccessIcon(with: icon))
                
            case let amount as PaymentParameterAmount:
                let currencySymbol = dictionaryCurrencySymbol(for: "RUB") ?? "₽"
                let value: String? = {
                    guard let amountDecimalValue = amount.value else {
                        return nil
                    }
                    return NSDecimalNumber(decimal: amountDecimalValue).stringValue
                }()
                let amountParameter = Payments.ParameterAmount(value: value, title: amount.title, currencySymbol: currencySymbol, transferButtonTitle: "Оплатить", validator: .init(minAmount: 0.01, maxAmount: 1000000), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
                
                parameters.append(amountParameter)
                
            case let link as PaymentParameterLink:
                parameters.append(Payments.ParameterSuccessLink(with: link))
                
            case let dataInt as PaymentParameterDataInt:
                parameters.append(Payments.ParameterDataValue(parameter: .init(id: Payments.Parameter.Identifier.successOperationDetailID.rawValue, value: dataInt.value.description)))
                
            default:
                continue
            }
        }

        return parameters
    }
}

extension Array where Element == AnyPaymentParameter {
    
    var precondition: Payments.ParameterSubscribe.Button.Precondition? {
        
        hasTermsCheck ? .init(parameterId: "terms_check", value: "true") : nil
    }
    
    private var hasTermsCheck: Bool {
        
        map(\.id).contains("terms_check")
    }
}

extension Payments.ParameterProduct {
    
    init(with data: PaymentParameterProductSelect, firstProduct: (ProductData.Filter) -> ProductData?) throws {
        
        let filter = ProductData.Filter.c2bFilter(
            productTypes: data.filter.productTypes,
            currencies: data.filter.currencies,
            additional: data.filter.additional
        )
        
        guard let product = firstProduct(filter) else {
            throw Payments.Error.unableCreateRepresentable(Payments.Parameter.Identifier.product.rawValue)
        }
        
        self.init(value: String(product.id), title: data.title, filter: filter, isEditable: true)
    }
    
    init(with data: PaymentParameterProductSelect, product: ProductData) {
        
        let filter = ProductData.Filter.c2bFilter(
            productTypes: data.filter.productTypes,
            currencies: data.filter.currencies,
            additional: data.filter.additional
        )

        self.init(value: String(product.id), title: data.title, filter: filter, isEditable: true)
    }
}

extension Payments.ParameterCheck {
    
    init(with data: PaymentParameterCheck) {
        
        self.init(
            .init(id: data.id, value: String(data.value)),
            title: data.link.title,
            urlString: data.link.url.absoluteString,
            style: .c2bSubscription
        )
    }
}

//MARK: update depependend parameters
func paymentsProcessDependencyReducerC2B(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
    
    switch parameterId {
    case Payments.Parameter.Identifier.subscribe.rawValue:
        
        guard parameters.map({ $0.id }).contains("terms_check") else {
            return nil
        }
        
        let subscribeParamId = Payments.Parameter.Identifier.subscribe.rawValue
        guard let subscribeParameter = parameters.first(where: { $0.id == subscribeParamId }) as? Payments.ParameterSubscribe else {
            return nil
        }
        
        return subscribeParameter
    
    default:
        return nil
    }
}

//MARK: Helpers

extension Result {
    
    init(catching body: () async throws -> Success) async where Failure == Error {
        
        do {
            let success = try await body()
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
}
