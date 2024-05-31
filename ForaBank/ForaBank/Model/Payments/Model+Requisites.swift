//
//  Model+Requisites.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.12.2022.
//

import Foundation
import UIKit

extension Model {
    
    typealias SCSuggestionsCompany = [ServerCommands.SuggestController.SuggestCompany.Response.SuggestionsCompany]
    typealias SCGetBicAccountCheck = ServerCommands.PaymentOperationDetailContoller.GetBicAccountCheck
    typealias SCSuggestCompany = ServerCommands.SuggestController.SuggestCompany
    
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
            let headerParameter: Payments.ParameterHeader = parameterHeader(
                source: operation.source,
                header: .init(
                    title: "Перевести",
                    subtitle: "Человеку или организации",
                    icon: nil,
                    rightButton: [.init(icon: ImageData(named: "ic24BarcodeScanner2") ?? .iconPlaceholder,
                                        action: .scanQrCode)])
            )
            
            //MARK: Bic Bank Parameter
            let banks = self.dictionaryFullBankInfoPrefferedFirstList()
            let options = banks.map({Payments.ParameterSelectBank.Option(id: $0.bic, name: $0.rusName ?? $0.fullName, subtitle: $0.bic, icon: .init(with: $0.svgImage), isFavorite: false, searchValue: $0.bic)})

            let bicBankParameter = Payments.ParameterSelectBank(.init(id: bicBankId, value: nil), icon: defaultInputIcon, title: "БИК банка получателя", options: options, placeholder: "Начните ввод для поиска", selectAll: .init(type: .banksFullInfo), keyboardType: .number)
            
            //MARK: Account Number Parameter
            let accountNumberValidator: Payments.Validation.RulesSystem = {
                
                var rules = [any PaymentsValidationRulesSystemRule]()
                
                rules.append(Payments.Validation.LengthLimitsRule(lengthLimits: [20], actions: [.post: .warning("Должен состоять из 20 цифр.")]))
                
                rules.append(Payments.Validation.RegExpRule(regExp: "^[0-9]\\d*$", actions: [.post: .warning("Введены недопустимые символы")]))
                
                rules.append(Payments.Validation.RegExpRule(regExp: "\\d{5}810\\d{12}|\\d{5}643\\d{12}$", actions: [.post: .warning("Введите номер рублевого счета")]))
                
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
            
            let command = SCGetBicAccountCheck(token: token, payload: .init(bic: bicValue, account: accountNumberValue))
            
            let result = try await serverAgent.executeCommand(command: command)
            
            let requisitesTypeParameter = Payments.ParameterRequisitesType(type: result.checkResult)
            
            //MARK: Inn Number Parameter
            let validator: Payments.Validation.RulesSystem = {
                
                var rules = [any PaymentsValidationRulesSystemRule]()
                
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
                    
                    var rules = [any PaymentsValidationRulesSystemRule]()
                    
                    rules.append(Payments.Validation.MaxLengthRule(maxLenght: 210, actions: [.post: .warning("Заполните поле (до 210 символов)")]))
                    
                    return .init(rules: rules)
                }()
                
                //MARK: Message Parameter
                var messageValue: String?
                switch operation.source {
                case .template:
                    messageValue = nil
                default:
                    messageValue = "Перевод денежных средств. НДС не облагается"
                }
                
                let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: messageValue), icon: messageParameterIcon, title: "Назначение платежа", validator: messageValidator, limitator: .init(limit: 210))
                
                //MARK: Product Parameter
                let productParameterId = Payments.Parameter.Identifier.product.rawValue
                let filter = ProductData.Filter.generalFrom
                guard let product = firstProduct(with: filter),
                      let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                    throw Payments.Error.unableCreateRepresentable(productParameterId)
                }
                
                let productId = productWithSource(source: operation.source, productId: String(product.id))
                let productParameter = Payments.ParameterProduct(value: productId, filter: filter, isEditable: true)
                
                //MARK: Amount Parameter
                let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
                let amountParameter = Payments.ParameterAmount(value: nil, title: "Сумма перевода", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: .init(minAmount: 0.01, maxAmount: product.balance), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
                
                return .init(parameters: [nameParameter, messageParameter, productParameter, amountParameter, requisitesTypeParameter], front: .init(visible: [nameParameterId, messageParameterId, productParameterId, amountParameterId], isCompleted: false), back: .init(stage: .remote(.start), required: [nameParameter.id, messageParameter.id, productParameter.id, amountParameter.id], processed: nil))
                
            case .legal:
                return .init(parameters: [innParameter, requisitesTypeParameter], front: .init(visible: [innNumberId], isCompleted: false), back: .init(stage: .local, required: [innParameter.id], processed: nil))
                
            case .entrepreneurs:
                return .init(parameters: [innParameter, requisitesTypeParameter], front: .init(visible: [innNumberId], isCompleted: false), back: .init(stage: .local, required: [innParameter.id], processed: nil))
                
            case .budget:
                throw Payments.Error.action(.alert(title: "Сервис временно не доступен", message: "Приносим извинения за доставленные неудобства"))
                
            case .other:
                return .init(
                    parameters: [innParameter, requisitesTypeParameter],
                    front: .init(visible: [innNumberId], isCompleted: false),
                    back: .init(stage: .local, required: [innParameter.id], processed: nil)
                )
            }
            
        case 2:
            guard let token = token else {
                throw Payments.Error.notAuthorized
            }
            
            guard let innValue = operation.parameters.first(where: { $0.id == innNumberId })?.value else {
                throw Payments.Error.missingParameter(innNumberId)
            }
            
            let command = SCSuggestCompany(token: token, payload: .init(branchType: nil, kpp: nil, query: innValue, type: nil))
            let result = try await serverAgent.executeCommand(command: command)
            
            var parameters = [PaymentsParameterRepresentable]()
            
            //MARK: Kpp Parameter
            let kppParameterId = Payments.Parameter.Identifier.requisitsKpp.rawValue
            let kppParameterValidator: Payments.Validation.RulesSystem = validateKppParameter()
            
            //MARK: Company Name Parameter
            let companyNameParameterId = Payments.Parameter.Identifier.requisitsCompanyName.rawValue
            let companyNameValidator: Payments.Validation.RulesSystem = validateCompanyNameParameter()
            
            let suggestedCompanies: [(kpp: String?, name: String)] = extractSuggestedCompanies(result)
            
            if suggestedCompanies.isEmpty == false {
                
                if suggestedCompanies.count == 1 {
                    
                    if innValue.count == 10 {
                        
                        //MARK: Kpp Parameter
                        let kppParameter = createKppParameterInput(id: kppParameterId, value: suggestedCompanies[0].kpp, validator: kppParameterValidator)
                        parameters.append(kppParameter)
                    }
                    
                    let companyParameter = try getCompanyNameParameter(
                        operation,
                        companyNameParameterId,
                        companyNameValidator,
                        suggestedCompanies
                    )
                    parameters.append(companyParameter)
                    
                } else {
                    
                    //MARK: Kpp Parameter
                    let options: [Payments.ParameterSelect.Option] = createParameterOptions(suggestedCompanies)
                    
                    // MARK: Company Name Parameter
                    let companyNameValue = options.first?.subname
                    let companyNameParameter = Payments.ParameterInput(
                        .init(id: companyNameParameterId, value: companyNameValue),
                        icon: nil,
                        title: "Наименование получателя",
                        validator: companyNameValidator,
                        limitator: .init(limit: 160)
                    )
                    parameters.append(companyNameParameter)

                    if shouldShowKppParameter(operation.source, innValue.count) {
                        
                        let kppParameterSelect = Payments.ParameterSelect(
                            .init(id: kppParameterId, value: options.first?.id),
                            icon: .name("ic24FileHash"),
                            title: "КПП получателя",
                            placeholder: "Начните ввод для поиска",
                            options: options,
                            description: "Выберите из \(options.count)",
                            validator: validateKppParameter(),
                            keyboardType: .number
                        )
                        parameters.append(kppParameterSelect)
                       
                        // helper required to support update company name with kpp parameter selector change and manual user name update
                        let companyNameParameterHelperId = Payments.Parameter.Identifier.requisitsCompanyNameHelper.rawValue
                        let companyNameParameterHelper = Payments.ParameterHidden(
                            id: companyNameParameterHelperId,
                            value: companyNameValue
                        )
                        parameters.append(companyNameParameterHelper)
                    }
                }
                
            } else {
                
                // user shoud fill kpp and company name parameters
                
                if innValue.count == 10 {
                    
                    //MARK: Kpp Parameter
                    let kppParameter = createKppParameterInput(id: kppParameterId, validator: kppParameterValidator)
                    parameters.append(kppParameter)
                }
                
                // MARK: Company Name Parameter
                let companyNameParameter = Payments.ParameterInput(.init(id: companyNameParameterId, value: nil), icon: nil, title: "Наименование получателя", validator: companyNameValidator, limitator: .init(limit: 160))
                parameters.append(companyNameParameter)
            }
            
            if innValue.count == 10 {
                
                // MARK: CheckBox Parameter
                let checkBoxParameterId = Payments.Parameter.Identifier.requisitsCheckBox.rawValue
                let checkBoxParameter = Payments.ParameterCheck(
                    .init(id: checkBoxParameterId, value: .init()),
                    title: "Оплата ЖКХ",
                    urlString: nil,
                    mode: .requisites
                )
                parameters.append(checkBoxParameter)
            }
            
            // MARK: Message Parameter
            let messageValidator: Payments.Validation.RulesSystem = {
                
                var rules = [any PaymentsValidationRulesSystemRule]()
                
                rules.append(Payments.Validation.MinLengthRule(minLenght: 25, actions: [.post: .warning("Заполните поле (от 25 до 210 символов)")]))
                rules.append(Payments.Validation.MaxLengthRule(maxLenght: 210, actions: [.post: .warning("Заполните поле (от 25 до 210 символов)")]))
                
                return .init(rules: rules)
            }()
            
            let messageParameter = Payments.ParameterInput(.init(id: messageParameterId, value: nil), icon: messageParameterIcon, title: "Назначение платежа", validator: messageValidator, limitator: .init(limit: 210))
            parameters.append(messageParameter)
            
            //MARK: Product Parameter
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            guard let product = firstProduct(with: filter),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            
            let productId = productWithSource(source: operation.source, productId: String(product.id))
            let productParameter = Payments.ParameterProduct(value: productId, filter: filter, isEditable: true)
            parameters.append(productParameter)
            
            // MARK: Amount Parameter
            
            if case .requisites(let qrData) = operation.source {
                
                if let qrMapping = self.qrMapping.value {
                    
                    do {
                        
                        let amount: Double = try qrData.value(type: .general(.amount), mapping: qrMapping)
                        let amountParameter = createAmountParameter(value: String(amount), currencySymbol: currencySymbol, product: product)
                        parameters.append(amountParameter)
                        
                        return createOperationStep(parameters: parameters, isCompleted: false)
                        
                    } catch {
                        
                        let amountParameter = createAmountParameter(currencySymbol: currencySymbol, product: product)
                        parameters.append(amountParameter)
                        
                        return createOperationStep(parameters: parameters, isCompleted: false)
                    }
                    
                } else {
                    
                    let amountParameter = createAmountParameter(currencySymbol: currencySymbol, product: product)
                    parameters.append(amountParameter)
                    
                    return createOperationStep(parameters: parameters, isCompleted: false)
                }
                
            } else {
                
                let amountParameter = createAmountParameter(currencySymbol: currencySymbol, product: product, withMaxAmountInfinity: true)
                parameters.append(amountParameter)
                
                return createOperationStep(parameters: parameters, isCompleted: false)
            }
            
        default:
            throw Payments.Error.unsupported
        }
    }
    // MARK: Amount Parameter
    
    private func createAmountParameter(value: String? = nil, currencySymbol: String, product: ProductData, withMaxAmountInfinity: Bool = false) -> Payments.ParameterAmount {
        
        let validator: Payments.ParameterAmount.Validator
        
        if withMaxAmountInfinity {
            validator = .init(minAmount: 0.01, maxAmount: .infinity)
        } else {
            validator = .init(minAmount: 0.01, maxAmount: product.balance)
        }
        
        let info = Payments.ParameterAmount.Info.action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo)
        
        return Payments.ParameterAmount(value: value, title: "Сумма перевода", currencySymbol: currencySymbol, transferButtonTitle: "Продолжить", validator: validator, info: info)
    }

    private func createOperationStep(parameters: [PaymentsParameterRepresentable], isCompleted: Bool) -> Payments.Operation.Step {
        
        let visible = parameters.map { $0.id }
        let required = parameters.map { $0.id }
        
        return .init(parameters: parameters, front: .init(visible: visible, isCompleted: isCompleted), back: .init(stage: .remote(.start), required: required, processed: nil))
    }
    
    // MARK: - Case 2
    func validateKppParameter() -> Payments.Validation.RulesSystem {
        
        var rules = [any PaymentsValidationRulesSystemRule]()
        
        rules.append(Payments.Validation.LengthLimitsRule(lengthLimits: [9], actions: [.post: .warning("Должен состоять из 9 цифр.")]))
        
        rules.append(Payments.Validation.RegExpRule(regExp: "^[0-9]\\d*$", actions: [.post: .warning("Введено некорректное значение")]))
        
        return .init(rules: rules)
    }

    func validateCompanyNameParameter() -> Payments.Validation.RulesSystem {
        
        var rules = [any PaymentsValidationRulesSystemRule]()
        
        rules.append(Payments.Validation.MinLengthRule(minLenght: 1, actions: [.post: .warning("Заполните поле (до 160 символов)")]))
        rules.append(Payments.Validation.MaxLengthRule(maxLenght: 160, actions: [.post: .warning("Заполните поле (до 160 символов)")]))

        return .init(rules: rules)
    }
    
    func extractSuggestedCompanies(_ result: SCSuggestionsCompany) -> [(kpp: String?, name: String)] {
        return result.compactMap { company in
            guard let name = company.value else {
                return nil
            }
            return (company.data?.kpp, name)
        }
    }

    func hasSuggestedCompanies(_ suggestedCompanies: [(kpp: String?, name: String)]) -> Bool {
        return !suggestedCompanies.isEmpty
    }
    
    private func shouldShowKppParameter(_ source: Payments.Operation.Source?, _ innValueCount: Int) -> Bool {
        
        switch source {
        case .requisites:
            return innValueCount <= 10
        default:
            return true
        }
    }
    
    func createKppParameterInput(
        id: String,
        value: String? = nil,
        icon: ImageData? = nil,
        title: String = "КПП получателя",
        validator: Payments.Validation.RulesSystem,
        limit: Int = 9,
        inputType: Payments.ParameterInput.InputType = .number
    ) -> Payments.ParameterInput {
        
        return Payments.ParameterInput(
            .init(
                id: id,
                value: value
            ),
            icon: icon,
            title: title,
            validator: validator,
            limitator: .init(limit: limit),
            inputType: inputType
        )
    }
    
    func createParameterOptions(_ suggestedCompanies: [(kpp: String?, name: String)]) -> [Payments.ParameterSelect.Option] {
        
        return suggestedCompanies.compactMap { company in
            guard let kpp = company.kpp else {
                return nil
            }
            
            return .init(id: kpp, name: kpp, subname: company.name)
        }
    }
    
    func getCompanyNameParameter(
        _ operation: Payments.Operation,
        _ companyNameParameterId: String,
        _ companyNameValidator: Payments.Validation.RulesSystem,
        _ suggestedCompanies: [(kpp: String?, name: String)]
    ) throws -> PaymentsParameterRepresentable {
        
        // MARK: Company Name Parameter
        let title = "Наименование получателя"
        let limit = Payments.Limitation(limit: 160)
        
        switch operation.source {
        case let .template(templateId):
            
            guard let template = self.paymentTemplates.value.first(where: { $0.id == templateId }) else {
                throw Payments.Error.unsupported
            }
            
            let companyNameParameter = Payments.ParameterInput(
                .init(
                    id: companyNameParameterId,
                    value: template.name
                ),
                icon: nil,
                title: title,
                validator: companyNameValidator,
                limitator: limit
            )
             
            return companyNameParameter
            
        default:
            let companyNameParameter = Payments.ParameterInput(
                .init(
                    id: companyNameParameterId,
                    value: suggestedCompanies[0].name
                ),
                icon: nil,
                title: title,
                validator: companyNameValidator,
                limitator: limit
            )
            
            return companyNameParameter
        }
    }
    
    //MARK: process remote confirm step
    func paymentsProcessRemoteStepRequisits(
        operation: Payments.Operation,
        response: TransferResponseData
    ) async throws -> Payments.Operation.Step {

        var parameters = [PaymentsParameterRepresentable]()
        
        if let amountValue = response.debitAmount,
              let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: operation.parameters) {

            let amountParameterId = Payments.Parameter.Identifier.requisitsAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: .local("ic24Coins"),
                title: "Сумма перевода", placement: .feed)

            parameters.append(amountParameter)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .local("ic24PercentCommission"),
                title: "Комиссия", placement: .feed)
            
            parameters.append(feeParameter)
        }
            
        parameters.append(Payments.ParameterCode.regular)
            
        if response.scenario == .suspect {
            
            parameters.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "SUSPECT"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
        }
        
        return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.confirm), required: [], processed: nil))
    }
    
    //MARK: update depependend parameters
    func paymentsProcessDependencyReducerRequisits(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
        
        switch parameterId {
        case Payments.Parameter.Identifier.amount.rawValue:
            
            guard let amountParameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterAmount else {
                return nil
            }
        
            var currencySymbol = amountParameter.currencySymbol
            var maxAmount = amountParameter.validator.maxAmount
            
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            if let productParameter = parameters.first(where: { $0.id == productParameterId}) as? Payments.ParameterProduct,
               let productId = productParameter.productId,
               let product = product(productId: productId),
               let productCurrencySymbol = dictionaryCurrencySymbol(for: product.currency) {
                
                currencySymbol = productCurrencySymbol
                maxAmount = product.balance
            }
            
            let updatedAmountParameter = amountParameter.updated(currencySymbol: currencySymbol, maxAmount: maxAmount)
            
            guard updatedAmountParameter.currencySymbol != amountParameter.currencySymbol || updatedAmountParameter.validator != amountParameter.validator || updatedAmountParameter.info != amountParameter.info else {
                return nil
            }
            
            return updatedAmountParameter
            
        case Payments.Parameter.Identifier.requisitsMessage.rawValue:
            
            guard let messageParameter = try? parameters.parameter(forIdentifier: .requisitsMessage, as: Payments.ParameterInput.self),
                  let checkBoxParameter = try? parameters.parameter(forIdentifier: .requisitsCheckBox, as: Payments.ParameterCheck.self) else {
                return nil
            }
            
            // this logic drops unnecessary message parameter updates to fix lag durring fast message typing
            switch (checkBoxParameter.value, messageParameter.hint) {
            case (true, nil):
                // checkbox is enabled and hint is empty
                // create a hint
                return messageParameter.updated(hint: .init(title: "Назначение платежа", subtitle: "Заполняется в соответствии\nс требованиями поставщика услуг", icon: .init(named: "ic24Info") ?? .iconPlaceholder, hints: [.init(title: "Рекомендуемый формат:", description: "ЕЛС;период оплаты///назначение платежа, № и дата счета, адрес. Показания. НДС (есть/нет)."), .init(title: "Пример:", description: "ЛСИ1105-12;09.2022///оплата по счету 10 от 30.09.22, потребление э/э, показания 52364, адрес. В т.ч. НДС. л/с1631245;10.2022///платеж за кап ремонт, адрес. Без НДС.")]))
                
            case (false, .some):
                // checkbox is disabled and hint is NOT empty
                // remove the hint
                return messageParameter.updated(hint: nil)
                
            default:
                return nil
            }
            
        case Payments.Parameter.Identifier.header.rawValue:
            let codeParameterId = Payments.Parameter.Identifier.code.rawValue
            let parametersIds = parameters.map(\.id)
            guard parametersIds.contains(codeParameterId) else {
                return nil
            }
            return Payments.ParameterHeader(title: "Подтвердите реквизиты")
            
        case Payments.Parameter.Identifier.requisitsCompanyName.rawValue:
            
            // case when we have multiple kpps in selector
            // parameter KPP must be a ParameterSelect type
            // parameter company name helper also must be for this case
            
            guard let parameterKpp = try? parameters.parameter(forIdentifier: .requisitsKpp, as: Payments.ParameterSelect.self),
                  let parameterCompanyNameHelper = try? parameters.parameter(forIdentifier: .requisitsCompanyNameHelper),
                  let companyName = parameterKpp.options.first(where: { $0.id == parameterKpp.value })?.subname else {
                return nil
            }
            
            // check if value in helper Not equal to value in KPP selector
            // this means that KPP selector value changed
            guard parameterCompanyNameHelper.value != companyName else {
                return nil
            }
            
            guard let parameterCompanyName = try? parameters.parameter(forIdentifier: .requisitsCompanyName) else {
                return nil
            }
            
            // KPP selector value changed so we have to update the company name parameter value
            return parameterCompanyName.updated(value: companyName)
            
        case Payments.Parameter.Identifier.requisitsCompanyNameHelper.rawValue:
            guard let parameterKpp = try? parameters.parameter(forIdentifier: .requisitsKpp, as: Payments.ParameterSelect.self),
                  let parameterCompanyNameHelper = try? parameters.parameter(forIdentifier: .requisitsCompanyNameHelper),
                  let companyName = parameterKpp.options.first(where: { $0.id == parameterKpp.value })?.subname else {
                return nil
            }
            
            guard parameterCompanyNameHelper.value != companyName else {
                return nil
            }
            
            // store updated KPP value in parameter company name helper
            return parameterCompanyNameHelper.updated(value: companyName)
            
        default:
            return nil
        }
    }
    
    //MARK: - resets visible items and order
    
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
    
    //MARK: - Source Reducer
    // update parameter value with source
    func paymentsProcessSourceReducerRequisites(qrCode: QRCode, parameterId: Payments.Parameter.ID) -> Payments.Parameter.Value? {
        
        guard let qrMapping = self.qrMapping.value else {
            return nil
        }
        
        switch parameterId {
        case Payments.Parameter.Identifier.requisitsInn.rawValue:
            return qrCode.stringValue(type: .general(.inn), mapping: qrMapping)
            
        case Payments.Parameter.Identifier.requisitsAccountNumber.rawValue:
            return qrCode.stringValue(type: .general(.account), mapping: qrMapping)
            
        case Payments.Parameter.Identifier.requisitsBankBic.rawValue:
            return qrCode.stringValue(type: .general(.bic), mapping: qrMapping)

        case Payments.Parameter.Identifier.requisitsKpp.rawValue:
            return qrCode.stringValue(type: .general(.kpp), mapping: qrMapping)
        
        case Payments.Parameter.Identifier.requisitsCompanyName.rawValue:
            return qrCode.stringValue(type: .general(.name), mapping: qrMapping)
        
        case Payments.Parameter.Identifier.requisitsMessage.rawValue:
            return qrCode.stringValue(type: .general(.purpose), mapping: qrMapping)

        case Payments.Parameter.Identifier.requisitsAmount.rawValue:
            
            do {
             
                let amount: Double = try qrCode.value(type: .general(.amount), mapping: qrMapping)
                return String(amount)
                
            } catch {
                
                return nil
            }
            
        default:
            return nil
        }
    }
    
    func paymentsProcessSourceTemplateReducerRequisites(templateData: PaymentTemplateData?, parameterId: Payments.Parameter.ID) -> Payments.Parameter.Value? {
        
        guard let templateData = templateData,
              let parameters = templateData.parameterList.first as? TransferGeneralData else {
            return nil
        }
        
        switch parameterId {
        case Payments.Parameter.Identifier.requisitsName.rawValue:
            return parameters.payeeExternal?.name
                
        case Payments.Parameter.Identifier.requisitsInn.rawValue:
            return parameters.payeeExternal?.inn
            
        case Payments.Parameter.Identifier.requisitsAccountNumber.rawValue:
            return parameters.payeeExternal?.accountNumber

        case Payments.Parameter.Identifier.requisitsBankBic.rawValue:
            return parameters.payeeExternal?.bankBIC

        case Payments.Parameter.Identifier.requisitsKpp.rawValue:
            return parameters.payeeExternal?.kpp
        
        case Payments.Parameter.Identifier.requisitsCompanyName.rawValue:
            return parameters.payeeExternal?.name
        
        case Payments.Parameter.Identifier.requisitsMessage.rawValue:
            return parameters.comment
                
        default:
            return nil
        }
    }
}

extension Payments.ParameterAmount {
    
    func updated(currencySymbol: String, maxAmount: Double?) -> Payments.ParameterAmount {
            
        return Payments.ParameterAmount(value: value, title: "Сумма перевода", currencySymbol: currencySymbol, deliveryCurrency: deliveryCurrency, validator: .init(minAmount: 0.01, maxAmount: maxAmount), info: .action(title: "Возможна комиссия", .name("ic24Info"), .feeInfo))
    }
}

