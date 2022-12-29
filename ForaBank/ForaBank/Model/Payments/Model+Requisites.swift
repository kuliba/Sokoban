//
//  Model+Requisites.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.12.2022.
//

import Foundation
import UIKit

extension Model {
    
    func paymentsStepRequisites(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        let bicBankId = Payments.Parameter.Identifier.requisitsBankBic.rawValue
        let accountNumberId = Payments.Parameter.Identifier.requisitsAccountNumber.rawValue
        let innNumberId = Payments.Parameter.Identifier.requisitsInn.rawValue
        let messageParameterId = Payments.Parameter.Identifier.requisitsMessage.rawValue

        let defaultInputIcon = ImageData(named: "ic24FileHash") ?? .parameterSample
        let messageParameterIcon = ImageData(named: "ic24IconMessage") ?? .parameterSample
        
        switch stepIndex {
        case 0:
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .requisites)
            
            // header
            let headerParameter = Payments.ParameterHeader(title: "Перевести", subtitle: "Человеку или организации", icon: nil, rightButton: [.init(icon: ImageData(named: "ic24BarcodeScanner2") ?? .iconPlaceholder, action: .scanQrCode)])
            
            //MARK: Bic Bank Parameter
            let bicValidator: Payments.Validation.RulesSystem = {
                
                var rules = [Payments.Validation.Rule]()
                
                rules.append(Payments.Validation.LengthLimitsRule(lengthLimits: [9], actions: [.post: .warning("Должен состоять из 9 цифр.")]))

                rules.append(Payments.Validation.RegExpRule(regExp: "^[0-9]\\d*$", actions: [.post: .warning("Введено некорректное значение")]))
                
                return .init(rules: rules)
            }()
            let bicBankParameter = Payments.ParameterSelectBank(.init(id: bicBankId, value: nil), icon: defaultInputIcon, title: "Бик банка получателя", options: [], validator: bicValidator, limitator: .init(limit: 9))
            
            //MARK: Account Number Parameter
            let accountNumberValidator: Payments.Validation.RulesSystem = {
                
                var rules = [Payments.Validation.Rule]()

                rules.append(Payments.Validation.LengthLimitsRule(lengthLimits: [20], actions: [.post: .warning("Должен состоять из 20 цифр.")]))

                rules.append(Payments.Validation.RegExpRule(regExp: "^[0-9]\\d*$", actions: [.post: .warning("Введены недопустимые символы")]))

                return .init(rules: rules)
            }()
            let accountNumberParameter = Payments.ParameterInput(.init(id: accountNumberId, value: nil), icon: defaultInputIcon, title: "Номер счета получателя", validator: accountNumberValidator, limitator: .init(limit: 20), inputType: .number)
            
            return .init(parameters: [operatorParameter, headerParameter, bicBankParameter, accountNumberParameter], front: .init(visible: [headerParameter.id, bicBankId, accountNumberId], isCompleted: false), back: .init(stage: .local, required: [bicBankParameter.id, accountNumberParameter.id], processed: nil))
            
        case 1:
            guard let token = token else {
                throw Payments.Error.notAuthorized
            }
            
            guard let bicValue = operation.parameters.first(where: {$0.id == bicBankId})?.value else {
                throw Payments.Error.missingParameter(bicBankId)
            }
            
            guard let accountNumberValue = operation.parameters.first(where: {$0.id == accountNumberId})?.value else {
                throw Payments.Error.missingParameter(accountNumberId)
            }
            
            let command = ServerCommands.PaymentOperationDetailContoller.GetBicAccountCheck(token: token, payload: .init(bic: bicValue, account: accountNumberValue))
            
            let result = try await serverAgent.executeCommand(command: command)
            
            let requisitesTypeParameter = Payments.ParameterRequisitesType(type: result.checkResult)
            
            //MARK: Inn Number Parameter
            let validator: Payments.Validation.RulesSystem = {
                
                var rules = [Payments.Validation.Rule]()
                
                rules.append(Payments.Validation.LengthLimitsRule.init(lengthLimits: [10, 12], actions: [.post: .warning("Должен состоять из 10 или 12 цифр.")]))

                rules.append(Payments.Validation.RegExpRule(regExp: "^[0-9]\\d*$", actions: [.post: .warning("Введены недопустимые символы")]))
                
                return .init(rules: rules)
            }()
            
            let innParameter = Payments.ParameterInput(.init(id: innNumberId, value: nil), icon: defaultInputIcon, title: "ИНН получателя", validator: validator, limitator: .init(limit: 12), inputType: .number)
            
            switch result.checkResult {
                
            case .notValid:

                throw Payments.Error.action(.warning(parameterId: accountNumberId, message: "Счет не соответствует БИК"))
                
            case .individual:
                
                //MARK: Name Parameter
                let nameParameterId = Payments.Parameter.Identifier.requisitsName.rawValue
                let nameParameter = Payments.ParameterName(id: nameParameterId, value: nil, title: "ФИО Получателя")
                
                //MARK: Message parametr validation
                let messageValidator: Payments.Validation.RulesSystem = {
                    
                    var rules = [Payments.Validation.Rule]()
                    
                    rules.append(Payments.Validation.MaxLengthRule(maxLenght: 210, actions: [.post: .warning("Заполните поле (до 210 символов)")]))

                    return .init(rules: rules)
                }()
                
                //MARK: Message Parameter
                let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: "Перевод денежных средств. НДС не облагается"), icon: messageParameterIcon, title: "Назначение платежа", validator: messageValidator, limitator: .init(limit: 210))
                
                //MARK: Product Parameter
                let productParameterId = Payments.Parameter.Identifier.product.rawValue
                let filter = ProductData.Filter.generalFrom
                guard let product = firstProduct(with: filter),
                      let currencySymbol = dictionaryCurrencySymbol(for: product.currency)else {
                    throw Payments.Error.unableCreateRepresentable(productParameterId)
                }
                let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)
                
                //MARK: Amount Parameter
                let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
                let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма перевода", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: .init(minAmount: 0.01, maxAmount: product.balance), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
                
                return .init(parameters: [nameParameter, messageParameter, productParameter, amountParameter, requisitesTypeParameter], front: .init(visible: [nameParameterId, messageParameterId, productParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [nameParameter.id, messageParameter.id, productParameter.id, amountParameter.id], processed: nil))
                
            case .legal:
                return .init(parameters: [innParameter, requisitesTypeParameter], front: .init(visible: [innNumberId], isCompleted: false), back: .init(stage: .local, required: [innParameter.id], processed: nil))
                
            case .entrepreneurs:
                return .init(parameters: [innParameter, requisitesTypeParameter], front: .init(visible: [innNumberId], isCompleted: false), back: .init(stage: .local, required: [innParameter.id], processed: nil))
                
            case .budget:
                throw Payments.Error.action(.alert(title: "Сервис временно не доступен", message: "Приносим извинения за доставленные неудобства"))
                
            case .other:
                return .init(parameters: [innParameter, requisitesTypeParameter], front: .init(visible: [innNumberId], isCompleted: false), back: .init(stage: .local, required: [innParameter.id], processed: nil))
            }
            
        case 2:
            guard let token = token else {
                throw Payments.Error.notAuthorized
            }
            
            guard let innValue = operation.parameters.first(where: {$0.id == innNumberId})?.value else {
                throw Payments.Error.missingParameter(innNumberId)
            }
            
            let command = ServerCommands.SuggestController.SuggestCompany(token: token, payload: .init(branchType: nil, kpp: nil, query: innValue, type: nil))
            
            let result = try await serverAgent.executeCommand(command: command)
            
            //MARK: Company Name Parameter
            let validator: Payments.Validation.RulesSystem = {
                
                var rules = [Payments.Validation.Rule]()
                
                rules.append(Payments.Validation.MinLengthRule(minLenght: 1, actions: [.post: .warning("Заполните поле (до 160 символов)")]))
                rules.append(Payments.Validation.MaxLengthRule(maxLenght: 160, actions: [.post: .warning("Заполните поле (до 160 символов)")]))

                return .init(rules: rules)
            }()
            
            let companyNameParameterId = Payments.Parameter.Identifier.requisitsCompanyName.rawValue
            let companyNameParameter = Payments.ParameterInput(.init(id: companyNameParameterId, value: result.first?.data?.name?.full), icon: nil, title: "Наименование получателя", validator: validator, limitator: .init(limit: 160))
            
            //MARK: Product Parameter
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency)else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)
            
            //MARK: Amount Parameter
            let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
            let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма перевода", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: .init(minAmount: 0.01, maxAmount: product.balance), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
            
            if innValue.count == 10 {
                
                //MARK: CheckBox Parameter
                let checkBoxParameterId = Payments.Parameter.Identifier.requisitsCheckBox.rawValue
                let checkBoxParameter = Payments.ParameterCheckBox(.init(id: checkBoxParameterId, value: .init()), title: "Оплата ЖКХ")
                    
                //MARK: Kpp Parameter
                let validator: Payments.Validation.RulesSystem = {
                    
                    var rules = [Payments.Validation.Rule]()
                    
                    rules.append(Payments.Validation.LengthLimitsRule.init(lengthLimits: [9], actions: [.post: .warning("Должен состоять из 9 цифр.")]))
                    
                    rules.append(Payments.Validation.RegExpRule(regExp: "^[0-9]\\d*$", actions: [.post: .warning("Введено некорректное значение")]))
                    
                    return .init(rules: rules)
                }()
                
                let kppParameterId = Payments.Parameter.Identifier.requisitsKpp.rawValue
                let kppParameter = Payments.ParameterInput(.init(id: kppParameterId, value: result.first?.data?.kpp), icon: nil, title: "КПП получателя", validator: validator, limitator: .init(limit: 9), inputType: .number)
                
                //MARK: Message Parameter
                let messageValidator: Payments.Validation.RulesSystem = {
                    
                    var rules = [Payments.Validation.Rule]()
                    
                    rules.append(Payments.Validation.MinLengthRule(minLenght: 25, actions: [.post: .warning("Заполните поле (от 25 до 210 символов)")]))
                    rules.append(Payments.Validation.MaxLengthRule(maxLenght: 210, actions: [.post: .warning("Заполните поле (от 25 до 210 символов)")]))

                    return .init(rules: rules)
                }()
                
                let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: nil), icon: messageParameterIcon, title: "Назначение платежа", validator: messageValidator, limitator: .init(limit: 210))
                
                //MARK: Amount Parameter
                let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
                let amountParameter = Payments.ParameterAmount(value: "0", title: "Сумма перевода", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: .init(minAmount: 0.01, maxAmount: product.balance), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
                
                if companyNameParameter.value?.count == 0 {
                        
                    throw Payments.Error.action(.warning(parameterId: companyNameParameterId, message: "Счет не соответствует БИК"))
                }
                
                return .init(parameters: [kppParameter, companyNameParameter, checkBoxParameter, messageParameter, productParameter, amountParameter], front: .init(visible: [kppParameterId, companyNameParameterId, checkBoxParameterId, messageParameterId, productParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [companyNameParameter.id, messageParameter.id, productParameter.id, amountParameter.id], processed: nil))
            }
            
            if companyNameParameter.value?.count == 0 {
                    
                throw Payments.Error.action(.warning(parameterId: companyNameParameterId, message: "Счет не соответствует БИК"))
            }
            
            //MARK: Message Parameter
            let messageValidator: Payments.Validation.RulesSystem = {
                
                var rules = [Payments.Validation.Rule]()
                
                rules.append(Payments.Validation.MinLengthRule(minLenght: 25, actions: [.post: .warning("Заполните поле (от 25 до 210 символов)")]))
                rules.append(Payments.Validation.MaxLengthRule(maxLenght: 210, actions: [.post: .warning("Заполните поле (от 25 до 210 символов)")]))

                return .init(rules: rules)
            }()
            
            let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: nil), icon: messageParameterIcon, title: "Назначение платежа", validator: messageValidator, limitator: .init(limit: 210))
            
            return .init(parameters: [companyNameParameter, messageParameter, productParameter, amountParameter], front: .init(visible: [companyNameParameterId, messageParameterId, productParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [companyNameParameter.id, messageParameter.id, productParameter.id, amountParameter.id], processed: nil))
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    //MARK: process remote confirm step
    func paymentsProcessRemoteStepRequisits(operation: Payments.Operation, response: TransferResponseData) async throws -> Payments.Operation.Step {

        var parameters = [PaymentsParameterRepresentable]()
        
        if let amountValue = response.debitAmount,
              let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) {

            let amountParameterId = Payments.Parameter.Identifier.requisitsAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: "Сумма перевода", placement: .feed)

            parameters.append(amountParameter)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .init(named: "ic24PercentCommission") ?? .parameterDocument,
                title: "Комиссия", placement: .feed)
            
            parameters.append(feeParameter)
        }
            
        parameters.append(Payments.ParameterCode.regular)
            
        return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.confirm), required: [], processed: nil))
    }
    
    //MARK: update depependend parameters
    func paymentsProcessDependencyReducerRequisits(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        switch parameterId {
        case Payments.Parameter.Identifier.requisitsMessage.rawValue:
            
            let messageId = Payments.Parameter.Identifier.requisitsMessage.rawValue
            guard let message = parameters.first(where: {$0.id == messageId}) as? Payments.ParameterInput else {
                return nil
            }
            
            let checkBoxId = Payments.Parameter.Identifier.requisitsCheckBox.rawValue
            let checkBox = parameters.first(where: {$0.id == checkBoxId})
            
            guard let checkBox = checkBox as? Payments.ParameterCheckBox, checkBox.value == true, let imageData = UIImage(named: "ic24Info")?.pngData() else {
                return message.updated(hint: nil)
            }
            
            return message.updated(hint: .init(title: "Назначение платежа", subtitle: "Заполняется в соответствии\nс требованиями поставщика услуг", icon: imageData, hints: [.init(title: "Рекомендуемый формат:", description: "ЕЛС;период оплаты///назначение платежа, № и дата счета, адрес. Показания. НДС (есть/нет)."), .init(title: "Пример:", description: "ЛСИ1105-12;09.2022///оплата по счету 10 от 30.09.22, потребление э/э, показания 52364, адрес. В т.ч. НДС. л/с1631245;10.2022///платеж за кап ремонт, адрес. Без НДС.")]))
            
        case Payments.Parameter.Identifier.header.rawValue:
            let codeParameterId = Payments.Parameter.Identifier.code.rawValue
            let parametersIds = parameters.map{ $0.id }
            guard parametersIds.contains(codeParameterId) else {
                return nil
            }
            return Payments.ParameterHeader(title: "Подтвердите реквизиты")
        
        case Payments.Parameter.Identifier.requisitsKpp.rawValue:
            guard let parameterKpp = parameters.first(where: {$0.id == Payments.Parameter.Identifier.requisitsKpp.rawValue}) as? Payments.ParameterInput else {
                return nil
            }
            
            let kppParameterUpdated = parameterKpp.updated(icon: ImageData(named: "ic24FileHash") ?? .parameterSample)
            return kppParameterUpdated
            
        default:
            return nil
        }
    }
    
    //MARK: resets visible items and order
    func paymentsProcessOperationResetVisibleRequisits(_ operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        // check if current step stage is confirm
        guard case .remote(let remote) = operation.steps.last?.back.stage,
              remote == .confirm else {
            return nil
        }
        
        guard let type = operation.parameters.first(where: {$0.parameter.id == Payments.Parameter.Identifier.requisitsType.rawValue}), let parameter = type as? Payments.ParameterRequisitesType else {
            return nil
        }
        
        switch parameter.type {
        
        case .legal:
            return [Payments.Parameter.Identifier.header.rawValue,
                    Payments.Parameter.Identifier.requisitsBankBic.rawValue,
                    Payments.Parameter.Identifier.requisitsAccountNumber.rawValue,
                    Payments.Parameter.Identifier.requisitsInn.rawValue,
                    Payments.Parameter.Identifier.requisitsKpp.rawValue,
                    Payments.Parameter.Identifier.requisitsName.rawValue,
                    Payments.Parameter.Identifier.requisitsCompanyName.rawValue,
                    Payments.Parameter.Identifier.requisitsMessage.rawValue,
                    Payments.Parameter.Identifier.requisitsAmount.rawValue,
                    Payments.Parameter.Identifier.fee.rawValue,
                    Payments.Parameter.Identifier.code.rawValue]
            
        case .entrepreneurs:
            return [Payments.Parameter.Identifier.header.rawValue,
                    Payments.Parameter.Identifier.requisitsBankBic.rawValue,
                    Payments.Parameter.Identifier.requisitsAccountNumber.rawValue,
                    Payments.Parameter.Identifier.requisitsInn.rawValue,
                    Payments.Parameter.Identifier.requisitsKpp.rawValue,
                    Payments.Parameter.Identifier.requisitsName.rawValue,
                    Payments.Parameter.Identifier.requisitsCompanyName.rawValue,
                    Payments.Parameter.Identifier.requisitsMessage.rawValue,
                    Payments.Parameter.Identifier.requisitsAmount.rawValue,
                    Payments.Parameter.Identifier.fee.rawValue,
                    Payments.Parameter.Identifier.code.rawValue]
            
        default:
            return [Payments.Parameter.Identifier.header.rawValue,
                    Payments.Parameter.Identifier.requisitsBankBic.rawValue,
                    Payments.Parameter.Identifier.requisitsInn.rawValue,
                    Payments.Parameter.Identifier.requisitsKpp.rawValue,
                    Payments.Parameter.Identifier.requisitsAccountNumber.rawValue,
                    Payments.Parameter.Identifier.requisitsName.rawValue,
                    Payments.Parameter.Identifier.requisitsCompanyName.rawValue,
                    Payments.Parameter.Identifier.requisitsMessage.rawValue,
                    Payments.Parameter.Identifier.requisitsAmount.rawValue,
                    Payments.Parameter.Identifier.fee.rawValue,
                    Payments.Parameter.Identifier.code.rawValue]
        }
    }
}


