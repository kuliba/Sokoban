//
//  Model+PaymentsToAnotherCard.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 13.02.2023.
//

import Foundation

extension Model {
    
    func paymentsLocalStepToAnotherCard(_ operation: Payments.Operation,
                         for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        let group = Payments.Parameter.Group(id: "ToAnotherCardProductTemplateCroup", type: .regular)
        
        switch stepIndex {
        case 0:
            
            // Header
            let headerParameter: Payments.ParameterHeader = parameterHeader(
                source: operation.source,
                header: .init(title: "На другую карту")
            )

            //Product Parameter
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            
            guard let product = firstProduct(with: filter),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency)
            else { throw Payments.Error.unableCreateRepresentable(productParameterId) }
            
            let productId = productWithSource(source: operation.source, productId: String(product.id))
            let productParameter = Payments.ParameterProduct
                .init(value: productId,
                      title: "Откуда",
                      filter: filter,
                      isEditable: true,
                      group: group)
            
            //ProductTemplateParameter
            let productTemplateParameterId = Payments.Parameter.Identifier.productTemplate.rawValue
            let validatorValue: Payments.Validation.RulesSystem =
                .init(rules: [Payments.Validation.LengthLimitsRule(lengthLimits: [16],
                                                                   actions: [.post: .warning("Должен состоять из 16 цифр")])])
            let productTemplateParameter = Payments.ParameterProductTemplate
                .init(value: nil, validator: validatorValue, group: group, isEditable: true)
            
            //Amount Parameter
            let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
            let amountParameter = Payments.ParameterAmount
                .init(value: nil,
                      title: "",
                      currencySymbol: currencySymbol,
                      transferButtonTitle: "Продолжить",
                      validator: .init(minAmount: 0.01, maxAmount: product.balance),
                      info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
            
            return .init(parameters: [headerParameter, productParameter, productTemplateParameter, amountParameter],
                         front: .init(visible: [headerParameter.id,
                                                productParameterId,
                                                productTemplateParameterId,
                                                amountParameterId],
                                      isCompleted: false),
                         back: .init(stage: .local,
                                     required: [productParameterId, productTemplateParameterId],
                                     processed: nil))
       
        case 1:
            
            guard let token = token else { throw Payments.Error.notAuthorized }
            
            let productTemplateParameterId = Payments.Parameter.Identifier.productTemplate.rawValue
            
            guard let productTemplate = operation.parameters
                .first(where: {$0.id == productTemplateParameterId }) as? Payments.ParameterProductTemplate,
                  let productTemplateValue = productTemplate.parameterValue
                    
            else {
                
                throw Payments.Error.missingParameter(productTemplateParameterId)
            }
            
            switch productTemplateValue {
            case let .cardNumber(cardNumber):
                
                let serverCommand = ServerCommands.TransferController.CheckCard
                                    .init(token: token,
                                          payload: .init(cardNumber: cardNumber,
                                                         cryptoVersion: "0.0"))
                
                let result = try await serverAgent.executeCommand(command: serverCommand)
                
                if result.check { //this is ForaCard
                
                    //ProductTemplateName Parameter
                    let productTemplateNameParameterId = Payments.Parameter.Identifier.productTemplateName.rawValue
                    let productTemplateNameValidator: Payments.Validation.RulesSystem =
                        .init(rules: [Payments.Validation.MinLengthRule(minLenght: 3,
                                                                        actions: [.post: .warning("Минимум 3 символа")])])
                                      
                    let productTemplateNameParameter = Payments.ParameterInput
                        .init(.init(id: productTemplateNameParameterId, value: ""),
                              icon: nil,
                              title: "Назовите, чтобы сохранить карту",
                              validator: productTemplateNameValidator,
                              limitator: .init(limit: 100),
                              group: group)
                    
                    return .init(parameters: [productTemplateNameParameter],
                                 front: .init(visible: [productTemplateNameParameterId], isCompleted: false),
                                 back: .init(stage: .remote(.start), required: [], processed: nil))
                    
                } else {
                    
                    return .init(parameters: [],
                                 front: .init(visible: [], isCompleted: true),
                                 back: .init(stage: .remote(.start), required: [], processed: nil))
                }
                
            case .templateId:
                
                return .init(parameters: [],
                             front: .init(visible: [], isCompleted: true),
                             back: .init(stage: .remote(.start), required: [], processed: nil))
            }
         
        default: throw Payments.Error.unsupported
            
        }
    }
    
//MARK: process remote confirm step
    func paymentsProcessRemoteStepToAnotherCard(
        operation: Payments.Operation,
        response: TransferResponseData
    ) async throws -> Payments.Operation.Step {

        var parameters = [PaymentsParameterRepresentable]()
        let group = Payments.Parameter.Group(id: UUID().uuidString, type: .info)
        
        if let amountValue = response.debitAmount,
              let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) {

            let amountParameterId = Payments.Parameter.Identifier.requisitsAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: .local("ic24Coins"),
                title: "Сумма перевода", placement: .feed, group: group)

            parameters.append(amountParameter)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .local("ic24PercentCommission"),
                title: "Комиссия", placement: .feed, group: group)
            
            parameters.append(feeParameter)
        }
            
        if response.scenario == .suspect {
            
            parameters.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "SUSPECT"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
        }
        
        parameters.append(Payments.ParameterCode.regular)
            
        return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.confirm), required: [], processed: nil))
    }
    
//MARK: update depependend parameters
    func paymentsProcessDependencyReducerToAnotherCard(parameterId: Payments.Parameter.ID,
                                                       parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        let parametersIds = parameters.map{ $0.id }
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        let codeParameterId = Payments.Parameter.Identifier.code.rawValue
        let productTemplateParameterId = Payments.Parameter.Identifier.productTemplate.rawValue
        let headerParameterId = Payments.Parameter.Identifier.header.rawValue
        let productTemplateNameParameterId = Payments.Parameter.Identifier.productTemplateName.rawValue

        switch parameterId {
            
        case Payments.Parameter.Identifier.amount.rawValue:
            
            guard let amountParameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterAmount
            else { return nil }
        
            var currencySymbol = amountParameter.currencySymbol
            var maxAmount = amountParameter.validator.maxAmount
            
            if let productParameter = parameters.first(where: { $0.id == productParameterId}) as? Payments.ParameterProduct,
               let productId = productParameter.productId,
               let product = product(productId: productId),
               let productCurrencySymbol = dictionaryCurrencySymbol(for: product.currency) {
                
                currencySymbol = productCurrencySymbol
                maxAmount = product.balance
            }
            
            let updatedAmountParameter = amountParameter.updated(currencySymbol: currencySymbol, maxAmount: maxAmount)
            
            guard updatedAmountParameter.currencySymbol != amountParameter.currencySymbol
                    || updatedAmountParameter.validator != amountParameter.validator
                    || updatedAmountParameter.info != amountParameter.info
            else {
                return nil
            }
            
            return updatedAmountParameter
            
            
        case headerParameterId:
            if parametersIds.contains(codeParameterId) {
                return Payments.ParameterHeader(title: "Подтвердите реквизиты")
            }
        
        case productTemplateParameterId:
           
            guard let parameterProductTemplate = parameters.first(where: {$0.id == productTemplateParameterId}) as? Payments.ParameterProductTemplate
            else { return nil }
            
            //block editable ProductTemplateParameter in inputTemplateName step
            if parametersIds.contains(productTemplateNameParameterId) {
                return parameterProductTemplate.updated(isEditable: false)
            }
            
        default: return nil
        }
        
        return nil
    }
    
//MARK: - resets visible items and order
    
    func paymentsProcessOperationResetVisibleToAnotherCard(_ operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        // check if current step stage is confirm
        guard case .remote(let remote) = operation.steps.last?.back.stage,
              remote == .confirm else {
            return nil
        }
        
        return [Payments.Parameter.Identifier.header.rawValue,
                Payments.Parameter.Identifier.product.rawValue,
                Payments.Parameter.Identifier.productTemplate.rawValue,
                Payments.Parameter.Identifier.requisitsAmount.rawValue,
                Payments.Parameter.Identifier.fee.rawValue,
                Payments.Parameter.Identifier.code.rawValue]
    }
    
}
