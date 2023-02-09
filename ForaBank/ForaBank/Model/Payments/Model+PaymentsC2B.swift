//
//  Model+PaymentsC2B.swift
//  ForaBank
//
//  Created by Max Gribov on 02.02.2023.
//

import Foundation

extension Model {
    
    func paymentsStepC2B(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            guard let source = operation.source else {
                throw Payments.Error.unsupported
            }
            
            switch source {
            case .c2bSubscribe(let url):
                guard let token = token else {
                    throw Payments.Error.notAuthorized
                }
                
                let command = ServerCommands.SBPController.GetScenarioQRData(token: token, payload: .init(QRLink: url.absoluteString))
                let response = try await serverAgent.executeCommand(command: command)
                
                var parameters = [PaymentsParameterRepresentable]()
                
                // header
                let headerParameter = Payments.ParameterHeader(title: "Привязка счета", subtitle: nil, icon: nil, rightButton: [])
                parameters.append(headerParameter)
                
                // response parameters
                parameters.append(contentsOf: try paymentsC2BReduceScenarioData(data: response))
                
                // subscribe
                if response.parameters.map({ $0.id }).contains("terms_check") {
                    
                    let subscribeParameter = Payments.ParameterSubscribe(buttons: [.init(title: "Привязать счет", style: .primary, action: .confirm, precondition: .init(parameterId: "terms_check", value: "true")), .init(title: "Пока нет", style: .secondary, action: .deny, precondition: nil)], icon: "ic72Sbp")
                    parameters.append(subscribeParameter)
                    
                } else {
                    
                    let subscribeParameter = Payments.ParameterSubscribe(buttons: [.init(title: "Привязать счет", style: .primary, action: .confirm, precondition: nil), .init(title: "Пока нет", style: .secondary, action: .deny, precondition: nil)], icon: "ic72Sbp")
                    parameters.append(subscribeParameter)
                }
                
                let visible = parameters.map{ $0.id }
                
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

        let subscribeParamId = Payments.Parameter.Identifier.subscribe.rawValue
        guard let subscribeParam = operation.parameters.first(where: { $0.id == Payments.Parameter.Identifier.subscribe.rawValue }) else {
            throw Payments.Error.missingParameter(subscribeParamId)
        }
        
        guard let subscribeValue = subscribeParam.value,
              let actionType = Payments.ParameterSubscribe.Button.Action(rawValue: subscribeValue) else {
            throw Payments.Error.missingValueForParameter(subscribeParamId)
        }
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let qrcIdParamId = Payments.Parameter.Identifier.c2bQrcId.rawValue
        guard let qrcParam = operation.parameters.first(where: { $0.id == qrcIdParamId }) else {
            throw Payments.Error.missingParameter(qrcIdParamId)
        }
        
        guard let qrcIdParamValue = qrcParam.value else {
            throw Payments.Error.missingValueForParameter(qrcIdParamId)
        }
        
        switch actionType {
        case .confirm:
            let productParamId = Payments.Parameter.Identifier.product.rawValue
            guard let productParam = operation.parameters.first(where: { $0.id == productParamId }) else {
                throw Payments.Error.missingParameter(productParamId)
            }
            
            guard let productIdString = productParam.value,
                  let productId = Int(productIdString),
                  let product = product(productId: productId) else {
                throw Payments.Error.missingValueForParameter(productParamId)
            }

            switch product {
            case let card as ProductCardData:
                let command = ServerCommands.SubscriptionController.ConfirmC2BSubscription(token: token, payload: .init(qrcId: qrcIdParamValue, cardId: String(card.id), accountId: nil))
                let result = try await serverAgent.executeCommand(command: command)
                
                //FIXME: update after the Payments.Success is refactored into dynamic parameters list
                return .init(operationDetailId: 0, status: .complete, productId: productId, amount: 0, service: .c2b, c2bSubscribtion: result)
                
            case let account as ProductAccountData:
                let command = ServerCommands.SubscriptionController.ConfirmC2BSubscription(token: token, payload: .init(qrcId: qrcIdParamValue, cardId: nil, accountId: String(account.id)))
                let result = try await serverAgent.executeCommand(command: command)
                
                //FIXME: update after the Payments.Success is refactored into dynamic parameters list
                return .init(operationDetailId: 0, status: .complete, productId: productId, amount: 0, service: .c2b, c2bSubscribtion: result)
                
            default:
                throw Payments.Error.unexpectedProductType(product.productType)
            }

        case .deny:
            let command = ServerCommands.SubscriptionController.DeniedC2BSubscription(token: token, payload: .init(qrcId: qrcIdParamValue))
            let result = try await serverAgent.executeCommand(command: command)
            
            //FIXME: update after the Payments.Success is refactored into dynamic parameters list
            return .init(operationDetailId: 0, status: .complete, productId: 0, amount: 0, service: .c2b, c2bSubscribtion: result)
        }
    }
    
    func paymentsC2BReduceScenarioData(data: QRScenarioData) throws -> [PaymentsParameterRepresentable] {
        
        var parameters = [PaymentsParameterRepresentable]()
        
        for parameterData in data.parameters {
            
            switch parameterData.parameter {
            case let subscriber as QRScenarioParameterSubscriber:
                parameters.append(Payments.ParameterSubscriber(.init(id: subscriber.id, value: subscriber.value), icon: subscriber.icon, description: subscriber.subscriptionPurpose))
                
            case let productSelect as QRScenarioParameterProductSelect:
                parameters.append(try Payments.ParameterProduct(with: productSelect, firstProduct: { filter in firstProduct(with: filter)}))
                
            case let check as QRScenarioParameterCheck:
                parameters.append(Payments.ParameterCheck(with: check))
                
            default:
                continue
            }
        }

        return parameters
    }
}

extension Payments.ParameterProduct {
    
    init(with data: QRScenarioParameterProductSelect, firstProduct: (ProductData.Filter) -> ProductData?) throws {
        
        var rules = [ProductDataFilterRule]()
        rules.append(ProductData.Filter.ProductTypeRule(Set(data.filter.productTypes)))
        rules.append(ProductData.Filter.CurrencyRule(Set(data.filter.currencies)))
        if data.filter.additional == false {
            
            rules.append(ProductData.Filter.CardAdditionalOwnedRetrictedRule())
            rules.append(ProductData.Filter.CardAdditionalNotOwnedRetrictedRule())
        }
        
        let filter = ProductData.Filter(rules: rules)
        guard let product = firstProduct(filter) else {
            throw Payments.Error.unableCreateRepresentable(Payments.Parameter.Identifier.product.rawValue)
        }
        self.init(value: String(product.id), title: data.title, filter: filter, isEditable: true)
    }
}

extension Payments.ParameterCheck {
    
    init(with data: QRScenarioParameterCheck) {
        
        var value: Payments.Parameter.Value = nil
        if let checkValue = data.value {
            value = String(checkValue)
        }
        
        self.init(.init(id: data.id, value: value), title: data.link.title, link: .init(title: data.link.subtitle, url: data.link.url), style: .c2bSubscribtion)
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
