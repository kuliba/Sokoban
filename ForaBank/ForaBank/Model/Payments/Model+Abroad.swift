//
//  Model+Country.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 26.01.2023.
//

import Foundation

extension Model {
    
    func paymentsStepDirect(_ operation: Payments.Operation, for stepIndex: Int) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            
            guard let source = operation.source else {
                throw Payments.Error.missingSource(operation.service)
            }
            
            guard case let .direct(phone: phone, countryId: country) = source else {
                
                throw Payments.Error.missingSource(operation.service)
            }
            
            let countryWithService = self.countriesListWithSevice.value.first(where: {($0.code == country || $0.contactCode == country)})
            let operatorsList = self.dictionaryAnywayOperators()
            
            // header
            let headerParameter = Payments.ParameterHeader(title: "Переводы за рубеж", subtitle: "Денежные переводы МИГ", icon: .name("MigAvatar"), style: .large)
            
            let dropDownListId = Payments.Parameter.Identifier.countryDropDownList.rawValue
            
            var options: [Payments.ParameterSelectDropDownList.Option] = []
            
            if let services = countryWithService?.servicesList {
                
                for service in services {
                    
                    if let option = operatorsList?.filter({$0.code == service.code.rawValue}).first {
                        
                        options.append(.init(id: option.code, name: option.name, icon: option.logotypeList.first?.iconData))
                    }
                }
            }
                        
            guard let defaultService = options.first?.id,
                  let operatorParameterValue: Payments.Operator = .init(rawValue: defaultService) else {
                throw Payments.Error.missingValueForParameter(Payments.Parameter.Identifier.operator.rawValue)
            }
            
            let operatorParameter = Payments.ParameterOperator(operatorType: operatorParameterValue)
            
            let countryId = Payments.Parameter.Identifier.countrySelect.rawValue
            let countryParameter = Payments.ParameterSelectCountry(.init(id: countryId, value: countryWithService?.code), icon: .iconPlaceholder, title: "Страна получателя", options: [], validator: .anyValue, limitator: nil, group: .init(id: "top", type: .regular))
            
            // product
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalTo
            guard let product = firstProduct(with: filter) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)
            
            if countryWithService?.servicesList.first(where: {$0.isDefault == true}) != nil {
                
                let option = countryWithService?.servicesList.first(where: {$0.isDefault == true})?.code.rawValue
                
                let dropDownListParameter = Payments.ParameterSelectDropDownList.init(.init(id: dropDownListId, value: option), title: "Перевести", options: options)

                return .init(parameters: [operatorParameter, headerParameter, dropDownListParameter, countryParameter, productParameter], front: .init(visible: [headerParameter.id, dropDownListId, countryId], isCompleted: true), back: .init(stage: .remote(.start), required: [dropDownListId, countryId], processed: nil))
                
            } else {
                
                let dropDownListParameter = Payments.ParameterSelectDropDownList.init(.init(id: dropDownListId, value: defaultService), title: "Перевести", options: options)
                
                return .init(parameters: [operatorParameter, headerParameter, dropDownListParameter, countryParameter, productParameter], front: .init(visible: [headerParameter.id, dropDownListId, countryId], isCompleted: true), back: .init(stage: .remote(.start), required: [dropDownListId, countryId], processed: nil))
            }
            
        default:
            
            throw Payments.Error.unsupported
        }
    }
    
    //MARK: - Source Reducer
    // update parameter value with source
    func paymentsProcessSourceReducerCountry(countryId: CountryData.ID, phone: String?, bankId: BankData.ID? = nil, parameterId: Payments.Parameter.ID) -> Payments.Parameter.Value? {
        
        switch parameterId {
        case Payments.Parameter.Identifier.countrySelect.rawValue:
            return countryId
            
        case Payments.Parameter.Identifier.countryPhone.rawValue:
            return phone
            
        case Payments.Parameter.Identifier.countryBank.rawValue:
            return bankId
            
        default:
            return nil
        }
    }
    
    // update depependend parameters
    func paymentsProcessDependencyReducerAbroad(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {

        switch parameterId {
        case Payments.Parameter.Identifier.operator.rawValue:
            let dropDownListId = Payments.Parameter.Identifier.countryDropDownList.rawValue
            
            guard let service = parameters.first(where: { $0.id == dropDownListId}) as? Payments.ParameterSelectDropDownList,
                  let value = service.value?.description else {
                      return nil
                  }
            
            return Payments.ParameterOperator(operatorType: .init(rawValue: value) ?? .direct) //FIXME: fix unwrap
          
        case Payments.Parameter.Identifier.countryDropDownList.rawValue:
            
            guard let service = parameters.first(where: { $0.id == parameterId}) as? Payments.ParameterSelectDropDownList else {
                return nil
            }
            
            guard let country = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countrySelect.rawValue }) as? Payments.ParameterSelectCountry else {
                return nil
            }
            
            let countryWithService = self.countriesListWithSevice.value.first(where: {($0.code == country.value || $0.contactCode == country.value)})
            let operatorsList = self.dictionaryAnywayOperators()
            
            var options: [Payments.ParameterSelectDropDownList.Option] = []
            
            if let services = countryWithService?.servicesList {
                
                for service in services {
                    
                    if let option = operatorsList?.filter({$0.code == service.code.rawValue}).first {
                        
                        options.append(.init(id: option.code, name: option.name, icon: option.logotypeList.first?.iconData))
                    }
                }
            }
            
            let dropDownListParameter = Payments.ParameterSelectDropDownList.init(.init(id: service.id, value: options.first?.id), title: "Перевести", options: options)
            
            return dropDownListParameter
            
        case Payments.Parameter.Identifier.countrySelect.rawValue:
            let codeParameterId = Payments.Parameter.Identifier.code.rawValue
            let parametersIds = parameters.map{ $0.id }
            guard parametersIds.contains(codeParameterId) else {
                return nil
            }
            
            if let country = parameters.first(where: {$0.id == Payments.Parameter.Identifier.countrySelect.rawValue}) as? Payments.ParameterSelectCountry {
                
                return Payments.ParameterSelectCountry(country.parameter, icon: country.icon, title: "Страна получателя", options: [], validator: .anyValue, limitator: nil)
            } else {
                
                return nil
            }
            
        case Payments.Parameter.Identifier.amount.rawValue:
            guard parameters.first(where: {$0.id == Payments.Parameter.Identifier.code.rawValue}) == nil else {
                return nil
            }
            
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
            
            if let countryDeliveryCurrency = parameters.first(where: { $0.id ==  Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue}),
               let currencyValue = countryDeliveryCurrency.value,
               let currency = self.currencyList.value.first(where: {$0.code == currencyValue}),
               let symbol = currency.currencySymbol {
                
                currencySymbol = symbol
            }
            
            let updatedAmountParameter = amountParameter.update(currencySymbol: currencySymbol, maxAmount: maxAmount)
         
            return updatedAmountParameter
        
        case Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue:
            guard let countryDeliveryCurrency = parameters.first(where: {$0.id == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue}) as? Payments.ParameterHidden else {
                return nil
            }

            guard let amount = parameters.first(where: { $0.id == Payments.Parameter.Identifier.amount.rawValue }) as? Payments.ParameterAmount else {
                return nil
            }

            guard countryDeliveryCurrency.value != amount.deliveryCurrency?.selectedCurrency.description else {
                return nil
            }
            
            return countryDeliveryCurrency.updated(value: amount.deliveryCurrency?.selectedCurrency.description)
            
        case Payments.Parameter.Identifier.product.rawValue:
            guard var productParameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterProduct else {
                return nil
            }
            
            guard let filterCurriencies = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countryCurrencyFilter.rawValue }) else {
                
                var filter: ProductData.Filter = .init(rules: [])
                filter.rules.append(ProductData.Filter.DebitRule())
                filter.rules.append(ProductData.Filter.CurrencyRule(Set([.rub, .usd])))
                return productParameter.updated(filter: filter)
            }

            var currincies: [Currency] = []

            if let currienciesString = filterCurriencies.value?.components(separatedBy: " ") {
                
                for currincy in currienciesString {
                    
                    if currincy != "" {
                        
                        let currency = Currency.init(description: currincy)
                        currincies.append(currency)
                    }
                }
            }
            var filter: ProductData.Filter = .init(rules: [])
            filter.rules.append(ProductData.Filter.DebitRule())
            filter.rules.append(ProductData.Filter.CurrencyRule(Set(currincies)))
            
            if let product = self.firstProduct(with: filter),
               let productParameter = productParameter.updated(value: product.id.description) as? Payments.ParameterProduct {

                return productParameter.updated(filter: filter)

            } else {
                
                return productParameter.updated(filter: filter)
            }
            
            
        case Payments.Parameter.Identifier.header.rawValue:
            
            let codeParameterId = Payments.Parameter.Identifier.code.rawValue
            let parametersIds = parameters.map{ $0.id }
            if parametersIds.contains(codeParameterId) {
                
                return Payments.ParameterHeader(title: "Подтвердите реквизиты", icon: .name(""))//TODO: switch for image icon
            }
            
            guard let countrySwitch = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countryDropDownList.rawValue }) as? Payments.ParameterSelectDropDownList else {
                return nil
            }
            
            let title = "Переводы за рубеж"
            
            if let value =  countrySwitch.value,
               let puref = Payments.Operator(rawValue: value) {
                
                let `operator` = self.dictionaryAnywayGroupOperatorData(for: value)
                
                if let parentCode = `operator`?.parentCode,
                   let parentOperator = self.dictionaryAnywayOperatorGroup(for: parentCode) {
                    
                    switch puref {
                    case .contact, .contactCash:
                        let subtitle = "Денежные переводы CONTACT"
                        
                        if let svgImage = parentOperator.logotypeList.first?.svgImage,
                           let icon = ImageData(with: svgImage) {
                            
                            return Payments.ParameterHeader(title: title, subtitle: subtitle, icon: .image(icon), style: .large)
                            
                        } else {
                            
                            return Payments.ParameterHeader(title: title, subtitle: subtitle, icon: .name("ic24Abroad"), style: .large)
                            
                        }
                        
                    default:
                        let subtitle = "Денежные переводы МИГ"
                        if let iconData = parentOperator.logotypeList.first?.svgImage?.imageData {
                            
                            let icon = ImageData.init(data: iconData)
                            return Payments.ParameterHeader(title: title, subtitle: subtitle, icon: .image(icon), style: .large)
                            
                        } else {
                            
                            return Payments.ParameterHeader(title: title, subtitle: subtitle, icon: .name("ic24Abroad"), style: .large)
                        }
                    }
                }
            }
            
            return Payments.ParameterHeader(title: "Переводы за рубеж", subtitle: "Денежные переводы МИГ", icon: .name("MigAvatar"), style: .large)

            
        default:
            return nil
        }
    }
    
    func paymentsParameterRepresentableCountries(operation: Payments.Operation, parameterData: ParameterData) async throws -> PaymentsParameterRepresentable? {
        
        switch parameterData.view {
        case .select:
            switch parameterData.id {
            case Payments.Parameter.Identifier.countryDeliveryCurrencyDirect.rawValue:
                let deliveryCurrencyId = Payments.Parameter.Identifier.countryDeliveryCurrencyDirect.rawValue
                return Payments.ParameterHidden(id: deliveryCurrencyId, value: "RUB")
                
            case Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue:
                let deliveryCurrencyId = Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue
                let value = parameterData.options(style: .currency)?.compactMap({$0.id}).joined(separator: "-")
                let currency = value?.components(separatedBy: "-")
                
                var currencyArr: [Currency] = []
                
                if let currency = currency {
                    
                    for item in currency {
                        
                        currencyArr.append(Currency(description: item))
                    }
                }
                
                if let first = currencyArr.first {
                    
                    return Payments.ParameterHidden(id: deliveryCurrencyId, value: first.description)
                } else {
                    
                    return Payments.ParameterHidden(id: deliveryCurrencyId, value: value)
                }
                
            case Payments.Parameter.Identifier.countryBank.rawValue:
                guard let token = token else {
                    return nil
                }
                
                let command = ServerCommands.DictionaryController.GetDictionaryAnywayOperators(token: token, code: "BANK_MIG", codeParent: "AM")
                let result = try await serverAgent.executeCommand(command: command)
                
                var list: [Payments.ParameterSelectBank.Option] = []
                
                guard let imagesIds = result.list.first?.dictionaryList.compactMap({$0.md5hash}) else { return nil }
                
                let commandImages = ServerCommands.DictionaryController.GetSvgImageList(token: token, payload: .init(md5HashList: imagesIds))
                let images = try await serverAgent.executeCommand(command: commandImages)
                
                if let items = result.list.first?.dictionaryList {
                    
                    for item in items {
                        
                        let image = images.svgImageList.first(where: {$0.md5hash == item.md5hash})
                        
                        if let imageData = image?.svgImage, let svgData = ImageData.init(with: imageData) {
                            
                            list.append(Payments.ParameterSelectBank.Option.init(id: item.id, name: item.name, subtitle: nil, icon: svgData))
                        } else {
                            
                            list.append(Payments.ParameterSelectBank.Option.init(id: item.id, name: item.name, subtitle: nil, icon: .iconPlaceholder))
                        }
                    }
                }
                
                let bankId = Payments.Parameter.Identifier.countryBank.rawValue
                if let parameter = operation.parameters.first(where: {$0.id == "DIRECT_BANKS"}), let icon = list.first(where: {$0.name == parameter.value})?.icon {
                    
                    return Payments.ParameterSelectBank(.init(id: bankId, value: parameter.value), icon: icon, title: "Банк получателя", options: list, validator: .anyValue, limitator: nil, transferType: .abroad)
                    
                } else {
                    
                    return Payments.ParameterSelectBank(.init(id: bankId, value: nil), icon: .iconPlaceholder, title: "Банк получателя", options: list, validator: .anyValue, limitator: nil, transferType: .abroad)
                }
                
            default:
                guard let options = parameterData.options(style: .general) else {
                    return nil
                }
                
                return Payments.ParameterSelectSimple(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: parameterData.iconData ?? .parameterSample,
                    title: parameterData.title,
                    selectionTitle: "Выберете категорию",
                    options: options)
            }
            
        case .input:
            switch parameterData.id {
            case "bName":
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: parameterData.iconData ?? .parameterDocument,
                    title: parameterData.title,
                    validator: .baseName, group: .init(id: "fio", type: .contact))
                
            case "bLastName":
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: nil,
                    title: parameterData.title,
                    validator: .baseName, group: .init(id: "fio", type: .contact))
                
            case Payments.Parameter.Identifier.countrybSurName.rawValue:
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: nil,
                    title: parameterData.title,
                    validator: parameterData.validator, group: .init(id: "fio", type: .contact))
                
            case Payments.Parameter.Identifier.countryPhone.rawValue, "bPhone":
                let phoneId = Payments.Parameter.Identifier.countryPhone.rawValue
                if case let .direct(phone: phone, countryId: _) = operation.source {
                    
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: phone), title: parameterData.title, placeholder: parameterData.subTitle)
                    return phoneParameter
                } else {
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: nil), title: parameterData.title, placeholder: parameterData.subTitle)
                    return phoneParameter
                }
                
            case Payments.Parameter.Identifier.countryCitySearch.rawValue:
                guard let token = token else {
                    return nil
                }
                
                if let dataDictionary = parameterData.dataDictionary, let dataDictionaryРarent = parameterData.dataDictionaryРarent {
                    
                    let command = ServerCommands.DictionaryController.GetDictionaryAnywayOperators(token: token, code: dataDictionary, codeParent: dataDictionaryРarent)
                    let result = try await serverAgent.executeCommand(command: command)
                    
                    guard let list = result.list.first?.dictionaryList.map({Payments.ParameterSelect.Option(id: $0.id, name: $0.name, icon: nil)}) else { return nil }
                    return Payments.ParameterSelect(.init(id: parameterData.id, value: nil), icon: .parameterLocation, title: parameterData.title, placeholder: "Начните ввод для поиска", options: list, group: .init(id: "top", type: .regular))
                    
                } else {
                    
                    return nil
                }
                
            case Payments.Parameter.Identifier.countryBankSearch.rawValue:
                guard let token = token else {
                    return nil
                }
                
                if let dataDictionary = parameterData.dataDictionary, let dataDictionaryРarent = parameterData.dataDictionaryРarent {
                    
                    let command = ServerCommands.DictionaryController.GetDictionaryAnywayOperators(token: token, code: dataDictionary, codeParent: dataDictionaryРarent)
                    let result = try await serverAgent.executeCommand(command: command)
                    
                    guard let list = result.list.first?.dictionaryList.map({Payments.ParameterSelect.Option(id: $0.id, name: $0.name, subname: $0.subname, timeWork: $0.timeWork, currency: $0.codeValut, icon: nil)}) else { return nil }
                    return Payments.ParameterSelect(.init(id: parameterData.id, value: parameterData.value), icon: .init(named: "ic24Bank"), title: parameterData.title, placeholder: "Начните ввод для поиска", options: list, group: .init(id: "top", type: .regular))
                    
                } else {
                    
                    return nil
                }
            default:
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: parameterData.iconData ?? .parameterDocument,
                    title: parameterData.title,
                    validator: parameterData.validator)
            }
            
        case .info:
            return Payments.ParameterInfo(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterLocation,
                title: parameterData.title, group: .init(id: "info", type: .info))
            
        case .selectSwitch:
            return nil
        }
    }
    
    func paymentsProcessRemoteStepAbroad(operation: Payments.Operation, response: TransferResponseData) async throws -> Payments.Operation.Step {
        
        var parameters = [PaymentsParameterRepresentable]()
        
        if let customerName = response.payeeName {
            
            let countrySwitch = Payments.Parameter.Identifier.countryDropDownList.rawValue
            if let bankParameter = operation.parameters.first(where: { $0.id == countrySwitch }),
               let value = bankParameter.value,
               let options = Payments.Operator.init(rawValue: value) {
                
                switch options {
                case .direct:
                    let countryTransferNumberId = Payments.Parameter.Identifier.countryPayee.rawValue
                    let countryTransferNumber = Payments.ParameterInfo(
                        .init(id: countryTransferNumberId, value: customerName),
                        icon: .init(named: "ic24User") ?? .parameterDocument,
                        title: "Получатель", placement: .feed, group: .init(id: "confirm", type: .info))
                    
                    parameters.append(countryTransferNumber)
                    
                default:
                    let countryTransferNumberId = Payments.Parameter.Identifier.countryPayee.rawValue
                    let countryTransferNumber = Payments.ParameterInfo(
                        .init(id: countryTransferNumberId, value: customerName),
                        icon: .init(named: "ic24User") ?? .parameterDocument,
                        title: "Получатель", placement: .feed)
                    
                    parameters.append(countryTransferNumber)
                }
            }
        }
        
        if let payeeAmount = response.creditAmount,
           let currency = response.currencyPayee {
            
            let amount = self.amountFormatted(amount: payeeAmount, currencyCode: currency.description, style: .normal)

            let countryTransferNumberId = Payments.Parameter.Identifier.countryPayeeAmount.rawValue
            let countryTransferNumber = Payments.ParameterInfo(
                .init(id: countryTransferNumberId, value: amount),
                icon: .init(named: "ic24User") ?? .parameterDocument,
                title: "Сумма зачисления в валюте", placement: .feed, group: .init(id: "confirm", type: .info))
            
            parameters.append(countryTransferNumber)
        }
        
        if let amountValue = response.amount,
           let currencyPayee = response.currencyPayee {
            
            let amount = self.amountFormatted(amount: amountValue, currencyCode: currencyPayee.description, style: .normal)
            
            let amountParameterId = Payments.Parameter.Identifier.countryCurrencyAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amount),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: "Сумма перевода", placement: .feed, group: .init(id: "confirm", type: .info))
            
            parameters.append(amountParameter)
        }
        
        if let response = response as? TransferAnywayResponseData,
           let oferta = response.additionalList.first(where: {$0.fieldName == "oferta"}),
           let value = oferta.fieldValue,
           let url = URL(string: value) {
        
            let countryOferta = Payments.Parameter.Identifier.countryOferta.rawValue
            parameters.append(Payments.ParameterCheck(.init(id: countryOferta, value: "true"), title: "С договором", link: .init(title: "оферты", url: url), style: .c2bSubscribtion, mode: .abroad))
        }
        
        if let amountCurrency = response.debitAmount,
           let amountFormatted = paymentsAmountFormatted(amount: amountCurrency, parameters: operation.parameters){
            
            let amountParameterId = Payments.Parameter.Identifier.sfpAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: "Сумма списания", placement: .feed, group: .init(id: "confirm", type: .info))
            
            parameters.append(amountParameter)
        }
        
        if  let response = response as? TransferAnywayResponseData,
            let trnReference = response.additionalList.first(where: {$0.fieldName == "trnReference"}) {
            
            let countryTransferNumberId = Payments.Parameter.Identifier.countryTransferNumber.rawValue
            let countryTransferNumber = Payments.ParameterInfo(
                .init(id: countryTransferNumberId, value: trnReference.fieldValue),
                icon: .init(named: "ic24PercentCommission") ?? .parameterDocument,
                title: trnReference.fieldTitle ?? "Номер перевода", placement: .feed, group: .init(id: "confirm", type: .info))
            
            parameters.append(countryTransferNumber)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .init(named: "ic24PercentCommission") ?? .parameterDocument,
                title: "Комиссия", placement: .feed, group: .init(id: "confirm", type: .info))
            
            parameters.append(feeParameter)
        }
        
        if response.needOTP == true {
            
            parameters.append(Payments.ParameterCode.regular)
            
            return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.confirm), required: [], processed: nil))
            
        } else {
            
            return .init(parameters: parameters, front: .init(visible: parameters.map({ $0.id }), isCompleted: false), back: .init(stage: .remote(.next), required: [], processed: nil))
        }
    }
    
    func paymentsProcessAbroadComplete(code: String, operation: Payments.Operation) async throws -> Payments.Success {
        
        let response = try await paymentsTransferComplete(
            code: code
        )
        
        let success = try Payments.Success(
            with: response,
            operation: operation,
            serviceData: .abroadPayments(response)
        )
        
        return success
    }
    
    func paymentsProcessOperationResetVisibleCountry(_ operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        let restrictedIds = [Payments.Parameter.Identifier.countryId.rawValue,
                             Payments.Parameter.Identifier.countryCityId.rawValue,
                             Payments.Parameter.Identifier.trnPickupPointId.rawValue]
        
        // check if current step stage is confirm
        guard case .remote(let remote) = operation.steps.last?.back.stage,
              remote == .confirm else {
            
            let parameters = operation.visible.filter({!restrictedIds.contains($0)})
            return parameters
        }
        
        let countrySwitch = Payments.Parameter.Identifier.countryDropDownList.rawValue
        if let bankParameter = operation.parameters.first(where: { $0.id == countrySwitch }),
           let value = bankParameter.value,
           let options = Payments.Operator.init(rawValue: value) {
                
            switch options {
            case .contact, .contactCash:
                
                return [Payments.Parameter.Identifier.header.rawValue,
                        Payments.Parameter.Identifier.countrySelect.rawValue,
                        Payments.Parameter.Identifier.countryPayee.rawValue,
                        Payments.Parameter.Identifier.product.rawValue,
                        Payments.Parameter.Identifier.countryTransferNumber.rawValue,
                        Payments.Parameter.Identifier.countryCurrencyAmount.rawValue,
                        Payments.Parameter.Identifier.fee.rawValue,
                        Payments.Parameter.Identifier.sfpAmount.rawValue,
                        Payments.Parameter.Identifier.code.rawValue,
                        Payments.Parameter.Identifier.countryOferta.rawValue]
            case .direct:
                
                return [Payments.Parameter.Identifier.header.rawValue,
                        Payments.Parameter.Identifier.countryPhone.rawValue,
                        Payments.Parameter.Identifier.countryBank.rawValue,
                        Payments.Parameter.Identifier.product.rawValue,
                        Payments.Parameter.Identifier.countryPayee.rawValue,
                        Payments.Parameter.Identifier.countryTransferNumber.rawValue,
                        Payments.Parameter.Identifier.countryCurrencyAmount.rawValue,
                        Payments.Parameter.Identifier.fee.rawValue,
                        Payments.Parameter.Identifier.countryPayeeAmount.rawValue,
                        Payments.Parameter.Identifier.sfpAmount.rawValue,
                        Payments.Parameter.Identifier.code.rawValue]
            default:
                
                return [Payments.Parameter.Identifier.header.rawValue,
                        Payments.Parameter.Identifier.countrySelect.rawValue,
                        Payments.Parameter.Identifier.countryPayee.rawValue,
                        Payments.Parameter.Identifier.product.rawValue,
                        Payments.Parameter.Identifier.countryTransferNumber.rawValue,
                        Payments.Parameter.Identifier.countryCurrencyAmount.rawValue,
                        Payments.Parameter.Identifier.fee.rawValue,
                        Payments.Parameter.Identifier.sfpAmount.rawValue,
                        Payments.Parameter.Identifier.code.rawValue]
            }
        }
                    
        return [Payments.Parameter.Identifier.header.rawValue,
                Payments.Parameter.Identifier.countrySelect.rawValue,
                Payments.Parameter.Identifier.countryPayee.rawValue,
                Payments.Parameter.Identifier.product.rawValue,
                Payments.Parameter.Identifier.countryTransferNumber.rawValue,
                Payments.Parameter.Identifier.countryCurrencyAmount.rawValue,
                Payments.Parameter.Identifier.fee.rawValue,
                Payments.Parameter.Identifier.sfpAmount.rawValue,
                Payments.Parameter.Identifier.code.rawValue]
    }
}
