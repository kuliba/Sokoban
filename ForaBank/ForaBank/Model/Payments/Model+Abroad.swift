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
                
            var country: String?
            
            switch source {
            case let .direct(countryId: countryId):
                country = countryId.countryId.description
                    
            case let .template(templateId):
                        
                let template = self.paymentTemplates.value.first(where: { $0.id == templateId })
                
                guard let list = template?.parameterList as? [TransferAnywayData],
                    let additional = list.last?.additional else {
                    throw Payments.Error.missingSource(operation.service)
                }
                        
                country = additional.first(where: { $0.fieldname == Payments.Parameter.Identifier.countrySelect.rawValue })?.fieldvalue
            
            case let .latestPayment(latestPaymentId):
                guard let latestPayment = self.latestPayments.value.first(where: { $0.id == latestPaymentId }),
                      let latestPayment = latestPayment as? PaymentServiceData else {
                    throw Payments.Error.missingSource(operation.service)
                }
                
                country = latestPayment.additionalList.first(where: { $0.isCountry })?.fieldValue
                
            default:
                throw Payments.Error.missingSource(operation.service)
            }
                
            guard let country = country else {
                throw Payments.Error.missingSource(operation.service)
            }
                
            let countryWithService = self.countriesListWithSevice.value.first(where: {($0.code == country || $0.contactCode == country)})
            let operatorsList = self.dictionaryAnywayOperators()
            
            // header
            let headerParameter: Payments.ParameterHeader = parameterHeader(
                source: operation.source,
                header: .init(
                    title: "Переводы за рубеж",
                    subtitle: "Денежные переводы МИГ",
                    icon: .image(.init(named: "ic24Edit2") ?? .iconPlaceholder),
                    style: .large)
            )
            
            let dropDownListId = Payments.Parameter.Identifier.countryDropDownList.rawValue
            
            var options: [Payments.ParameterSelectDropDownList.Option] = []
            
            if let services = countryWithService?.servicesList {
                
                for service in services {
                    
                    if let option = operatorsList?.filter({$0.code == service.code.rawValue}).first {
                        
                        let icon: Payments.ParameterSelectDropDownList.Option.Icon? = {
                            
                            guard let imageData = option.logotypeList.first?.iconData else {
                                return nil
                            }
                            
                            return .image(imageData)
                        }()
                        
                        options.append(.init(id: option.code, name: option.name, icon: icon))
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
            
            let productId = Self.productWithSource(source: operation.source, productId: String(product.id))
            let productParameter = Payments.ParameterProduct(value: productId, filter: filter, isEditable: true)
            
            if countryWithService?.servicesList.first(where: { $0.isDefault == true }) != nil {
                
                let option = countryWithService?.servicesList.first(where: { $0.isDefault == true })?.code.rawValue
                
                let dropDownListParameter = Payments.ParameterSelectDropDownList(.init(id: dropDownListId, value: option), title: "Перевести", options: options)
                
                var parameters: [any PaymentsParameterRepresentable] = [operatorParameter,
                                                                       headerParameter,
                                                                       dropDownListParameter,
                                                                       countryParameter,
                                                                       productParameter]
                
                let paymentsSystemId = Payments.Parameter.Identifier.paymentSystem.rawValue

                if case .template = source {
                    
                    let countrySwitch = try parameters.parameter(forIdentifier: .countryDropDownList)
                    
                    if let value = countrySwitch.value,
                       let puref = Payments.Operator(rawValue: value) {
                        
                        let `operator` = self.dictionaryAnywayGroupOperatorData(for: value)
                        
                        if let parentCode = `operator`?.parentCode,
                           let parentOperator = self.dictionaryAnywayOperatorGroup(for: parentCode) {
                            
                            if let svgImage = parentOperator.logotypeList.last?.svgImage,
                               let icon = ImageData(with: svgImage) {
                                
                                switch puref {
                                case .contact, .contactCash:
                                    let value = "CONTACT"
                                    parameters.append(Payments.ParameterInput(.init(id: paymentsSystemId, value: value), icon: icon, title: "Платежная система", validator: .anyValue, isEditable: false, inputType: .default))
                                    
                                default:
                                    let value = "МИГ"
                                    parameters.append(Payments.ParameterInput(.init(id: paymentsSystemId, value: value), icon: icon, title: "Платежная система", validator: .anyValue, isEditable: false, inputType: .default))
                                }
                            }
                        }
                    }
                }
                
                return .init(parameters: parameters, front: .init(visible: [headerParameter.id, dropDownListId, paymentsSystemId, countryId], isCompleted: true), back: .init(stage: .remote(.start), required: [dropDownListId, countryId], processed: nil))
                
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
    func paymentsProcessSourceReducerCountry(countryId: CountryData.ID, phone: String?, bankId: BankData.ID? = nil, serviceData: PaymentServiceData?, parameterId: Payments.Parameter.ID) -> Payments.Parameter.Value? {
        
        if let serviceData = serviceData {
            
            return serviceData.additionalList.first(where: { $0.fieldName == parameterId } ).map(\.fieldValue)
            
        } else {
            
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
    }
    
    // update depependend parameters
    func paymentsProcessDependencyReducerAbroad(
        parameterId: Payments.Parameter.ID,
        parameters: [PaymentsParameterRepresentable],
        operation: Payments.Operation
    ) -> PaymentsParameterRepresentable? {
        
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
            
            guard let country = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countrySelect.rawValue }) as? Payments.ParameterSelectCountry,
                  let countryValue = country.parameter.value else {
                return nil
            }
            
            let countryWithService = self.countriesListWithSevice.value.first { $0.code == countryValue || $0.contactCode == countryValue }
            let operatorsList = self.dictionaryAnywayOperators()
            
            var options: [Payments.ParameterSelectDropDownList.Option] = []
            
            if let services = countryWithService?.servicesList {
                
                for service in services {
                    
                    if let option = operatorsList?.filter({$0.code == service.code.rawValue}).first {
                        
                        let icon: Payments.ParameterSelectDropDownList.Option.Icon? = {
                            
                            guard let imageData = option.logotypeList.first?.iconData else {
                                return nil
                            }
                            
                            return .image(imageData)
                        }()
                        
                        options.append(.init(id: option.code, name: option.name, icon: icon))
                    }
                }
            }
            
            guard service.options != options else {
                return nil
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
            guard !parameters.contains(where: { $0.id == Payments.Parameter.Identifier.code.rawValue }),
                let amountParameter = try? parameters.parameter(forIdentifier: .amount, as: Payments.ParameterAmount.self),
                  let productParameter = try? parameters.parameter(forIdentifier: .product, as: Payments.ParameterProduct.self),
                  let productId = productParameter.productId else {
                return nil
            }
            
            var currencySymbol = amountParameter.currencySymbol
            var maxAmount = amountParameter.validator.maxAmount
            
            if let product = product(productId: productId) {
                
                maxAmount = product.balance
            }
            
            if let countryDeliveryCurrency = try? parameters.parameter(forIdentifier: .countryDeliveryCurrency),
               let currencyValue = countryDeliveryCurrency.value,
               let currency = self.currencyList.value.first(where: { $0.code == currencyValue }),
               let symbol = currency.currencySymbol {
                
                currencySymbol = symbol
            }
            
            if let filterCurriencies = try? parameters.parameter(forIdentifier: .countryCurrencyFilter),
               let splittedCurrency = filterCurriencies.value?.components(separatedBy: ";"),
               splittedCurrency.count > 1 {
                
                let currenciesList = self.reduceDeliveryCurrency(productId: productId, splittedCurrency: splittedCurrency)
                let selectedCurrency = currenciesList.contains(where: { $0.description == amountParameter.deliveryCurrency?.selectedCurrency.description }) ? amountParameter.deliveryCurrency?.selectedCurrency : currenciesList.first
                
                let updatedAmountParameter = amountParameter.updated(value: amountParameter.value, deliveryCurrency: .init(selectedCurrency: selectedCurrency ?? .rub, currenciesList: currenciesList))
                
                guard let amountParameter = updatedAmountParameter as? Payments.ParameterAmount else {
                    return nil
                }

                switch operation.source {
                case let .template(templateId):
                    let template = self.paymentTemplates.value.first(where: { $0.id == templateId })
                    let parameterList = template?.parameterList.last as? TransferAnywayData
                    let currency = parameterList?.additional.first(where: { $0.fieldname == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue })
                    let selectedCurrency = self.currencyList.value.first(where: { $0.code == currency?.fieldvalue })
                    
                    if let currencySymbol = selectedCurrency?.currencySymbol,
                       let code = selectedCurrency?.code{
                        
                        let updateAmount = amountParameter.update(currencySymbol: currencySymbol, maxAmount: maxAmount) as? Payments.ParameterAmount
                        return updateAmount?.updated(value: amountParameter.value, deliveryCurrency: .init(selectedCurrency: .init(description: code), currenciesList: currenciesList))
                 
                    } else {
                        
                        return amountParameter.updated(currencySymbol: currencySymbol, maxAmount: maxAmount)
                    }
                default:
                    return amountParameter.updated(currencySymbol: currencySymbol, maxAmount: maxAmount)
                }
            }
            
            let updatedAmountParameter = amountParameter.update(currencySymbol: currencySymbol, maxAmount: maxAmount)
            
            return updatedAmountParameter
            
        case Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue:
            
            guard let countryDeliveryCurrency = try? parameters.parameter(forIdentifier: .countryDeliveryCurrency),
                  let amount = try? parameters.parameter(forIdentifier: .amount, as: Payments.ParameterAmount.self) else {
                return nil
            }

            guard countryDeliveryCurrency.value != amount.deliveryCurrency?.selectedCurrency.description else {
                return nil
            }
            
            return countryDeliveryCurrency.updated(value: amount.deliveryCurrency?.selectedCurrency.description)
            
        case Payments.Parameter.Identifier.product.rawValue:
            guard let productParameter = parameters.first(where: { $0.id == parameterId }) as? Payments.ParameterProduct else {
                return nil
            }
            
            guard let filterCurriencies = parameters.first(where: { $0.id == Payments.Parameter.Identifier.countryCurrencyFilter.rawValue }) else {
                return  nil
            }
            
            let filterCurrencies = self.reduceFilterCurrencies(filterCurrencies: filterCurriencies.value)
            
            let filter: ProductData.Filter = .init(rules: [
                ProductData.Filter.DebitRule(),
                ProductData.Filter.RestrictedDepositRule(),
                ProductData.Filter.CurrencyRule(Set(filterCurrencies)),
                ProductData.Filter.CardActiveRule(),
                ProductData.Filter.CardAdditionalNotOwnedRetrictedRule(),
                ProductData.Filter.AccountActiveRule()
            ])
            
            let productCurriencies = productParameter.filter.rules
                .currencyRules
                .first?.allowed ?? []
            
            let filteredCurriencies = filter.rules
                .currencyRules
                .first?.allowed ?? []
            
            guard productCurriencies != filteredCurriencies else {
                return nil
            }
            
            return productParameter.updated(filter: filter)
            
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
                
                //FIXME: do we really need server request here? this is dictionary
                let command = ServerCommands.DictionaryController.GetDictionaryAnywayOperators(token: token, code: "BANK_MIG", codeParent: "AM")
                let result = try await serverAgent.executeCommand(command: command)
                
                var list: [Payments.ParameterSelectBank.Option] = []
                
                guard let imagesIds = result.list.first?.dictionaryList.compactMap({$0.md5hash}) else { return nil }
                
                let commandImages = ServerCommands.DictionaryController.GetSvgImageList(token: token, payload: .init(md5HashList: imagesIds))
                let images = try await serverAgent.executeCommand(command: commandImages)
                
                if let items = result.list.first?.dictionaryList {
                    
                    for item in items {

                        
                        let icon: ImageData? = {
                            
                            guard let svgImage = images.svgImageList.first(where: { $0.md5hash == item.md5hash } )?.svgImage else {
                                return nil
                            }
                            
                            return .init(with: svgImage)
                        }()
                        
                        list.append(Payments.ParameterSelectBank.Option(id: item.id, name: item.name, subtitle: nil, icon: icon, searchValue: item.name))
                    }
                }
                
                let bankId = Payments.Parameter.Identifier.countryBank.rawValue
                if let parameter = operation.parameters.first(where: { $0.id == "DIRECT_BANKS" } ) {

                    return Payments.ParameterSelectBank(.init(id: bankId, value: parameter.value), icon: .iconPlaceholder, title: "Банк получателя", options: list, placeholder: "Начните ввод для поиска", keyboardType: .normal)

                } else {

                    return Payments.ParameterSelectBank(.init(id: bankId, value: nil), icon: .iconPlaceholder, title: "Банк получателя", options: list, placeholder: "Начните ввод для поиска", keyboardType: .normal)
                }
                
            default:
                guard let options = parameterData.options(style: .general) else {
                    return nil
                }
                
                let selectOptions = options
                    .compactMap{ $0 }
                    .map(Payments.ParameterSelect.Option.init)
                
                return Payments.ParameterSelect(.init(id: parameterData.id,
                                                      value: parameterData.value),
                                                title: "Выберете категорию",
                                                placeholder: "Начните ввод для поиска",
                                                options: selectOptions)
            }
            
        case .input:
            switch parameterData.id {
            case Payments.Parameter.Identifier.countryGivenName.rawValue:
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: parameterData.iconData ?? .parameterDocument,
                    title: parameterData.title,
                    validator: .baseName, group: .init(id: "fio", type: .contact))
                
            case Payments.Parameter.Identifier.countryMiddleName.rawValue:
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: nil,
                    title: parameterData.title,
                    validator: .baseName, group: .init(id: "fio", type: .contact))
                
            case Payments.Parameter.Identifier.countryFamilyName.rawValue:
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: nil,
                    title: parameterData.title,
                    validator: parameterData.validator, group: .init(id: "fio", type: .contact))
                
            case Payments.Parameter.Identifier.countryPhone.rawValue:
                let phoneId = Payments.Parameter.Identifier.countryPhone.rawValue
                if case let .direct(phone: phone, countryId: _, serviceData: _) = operation.source {
                    
                    // TODO: Create Model mock for testing
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: phone), title: parameterData.title, placeholder: parameterData.subTitle, countryCode: .armenian)
                    return phoneParameter
                    
                } else {
                    
                    // TODO: Create Model mock for testing
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: nil), title: parameterData.title, placeholder: parameterData.subTitle)
                    return phoneParameter
                }
                
            case Payments.Parameter.Identifier.countrybPhone.rawValue:
                let phoneId = Payments.Parameter.Identifier.countrybPhone.rawValue
                if case let .direct(phone: phone, countryId: _, serviceData: _) = operation.source {
                    
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: phone), title: parameterData.title, placeholder: parameterData.subTitle, countryCode: .turkey)
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
                    
                    guard let list = result.list.first?.dictionaryList.map({Payments.ParameterSelect.Option(id: $0.id, name: $0.name)}) else { return nil }
                    return Payments.ParameterSelect(.init(id: parameterData.id, value: nil), icon: .name("ic24MapPin"), title: parameterData.title, placeholder: "Начните ввод для поиска", options: list, group: .init(id: "top", type: .regular))
                    
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
                    
                    guard let list = result.list.first?.dictionaryList.map({Payments.ParameterSelect.Option(id: $0.id, name: $0.name, subname: $0.subname, timeWork: $0.timeWork, currenciesData: $0.codeValut)}) else { return nil }
                    return Payments.ParameterSelect(.init(id: parameterData.id, value: parameterData.value), icon: .name("ic24Bank"), title: parameterData.title, placeholder: "Начните ввод для поиска", options: list, group: .init(id: "top", type: .regular))
                    
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
            
            let countrySwitch = Payments.Parameter.Identifier.countryDropDownList.rawValue
            if let bankParameter = operation.parameters.first(where: { $0.id == countrySwitch }),
               let value = bankParameter.value,
               let options = Payments.Operator(rawValue: value) {
                
                switch options {
                case .direct, .cardKZ, .cardTJ, .cardUZ, .cardHumoUZ:
                    if let customerName = response.payeeName {
                        
                        let countryTransferNumberId = Payments.Parameter.Identifier.countryPayee.rawValue
                        let countryTransferNumber = Payments.ParameterInfo(
                            .init(id: countryTransferNumberId, value: customerName),
                            icon: .init(named: "ic24User") ?? .parameterDocument,
                            title: "Получатель", placement: .feed, group: .init(id: "confirm", type: .info))
                        
                        parameters.append(countryTransferNumber)
                        
                    }
                    
                    if let amountValue = response.amount,
                       let currencyPayer = response.currencyPayer {
                        
                        let amount = self.amountFormatted(amount: amountValue, currencyCode: currencyPayer.description, style: .normal)
                        
                        let amountParameterId = Payments.Parameter.Identifier.countryCurrencyAmount.rawValue
                        let amountParameter = Payments.ParameterInfo(
                            .init(id: amountParameterId, value: amount),
                            icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                            title: "Сумма перевода", placement: .feed, group: .init(id: "confirm", type: .info))
                        
                        parameters.append(amountParameter)
                    }
                    
                default:
                    if let customerName = response.payeeName {
                        
                        let countryTransferNumberId = Payments.Parameter.Identifier.countryPayee.rawValue
                        let countryTransferNumber = Payments.ParameterInfo(
                            .init(id: countryTransferNumberId, value: customerName),
                            icon: .init(named: "ic24User") ?? .parameterDocument,
                            title: "Получатель", placement: .feed)
                        
                        parameters.append(countryTransferNumber)
                    }
                    
                    if let amountValue = response.creditAmount,
                       let currencyPayee = response.currencyPayee {
                        
                        let amount = self.amountFormatted(amount: amountValue, currencyCode: currencyPayee.description, style: .normal)
                        
                        let amountParameterId = Payments.Parameter.Identifier.countryCurrencyAmount.rawValue
                        let amountParameter = Payments.ParameterInfo(
                            .init(id: amountParameterId, value: amount),
                            icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                            title: "Сумма перевода", placement: .feed, group: .init(id: "confirm", type: .info))
                        
                        parameters.append(amountParameter)
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
        
        if let response = response as? TransferAnywayResponseData,
           let oferta = response.additionalList.first(where: {$0.fieldName == "oferta"}),
           let value = oferta.fieldValue,
           let url = URL(string: value) {
            
            let countryOferta = Payments.Parameter.Identifier.countryOffer.rawValue
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
            serviceData: .abroadData(response)
        )
        
        return success
    }
    
    func paymentsProcessOperationResetVisibleCountry(_ operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        let restrictedIds = [Payments.Parameter.Identifier.countryId.rawValue,
                             Payments.Parameter.Identifier.countryCity.rawValue,
                             Payments.Parameter.Identifier.trnPickupPoint.rawValue]
        
        // check if current step stage is confirm
        guard operation.isConfirmCurrentStage else {
            
            let parameters = operation.steps.map( \.front.visible ).flatMap({ $0 })
            
            let restrictedParameters = parameters.filter({ !restrictedIds.contains($0) })
            return restrictedParameters
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
                        Payments.Parameter.Identifier.countryOffer.rawValue]
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

extension Model {
    
    func reduceDeliveryCurrency(productId: ProductData.ID, splittedCurrency: [String]) -> [Currency] {
        
        var clearCurrency = splittedCurrency
        clearCurrency.remove(at: 0)
        
        var deliveryCurrency: [Payments.ParameterAmount.DeliveryCurrency] = []
        
        for currency in clearCurrency {
            
            if let currency = self.deliveryCurrencyMapping(dataType: currency) {
                
                deliveryCurrency.append(currency)
            }
        }
        
        guard let product = self.product(productId: productId),
              let currencies = deliveryCurrency.first(where: { $0.selectedCurrency.description == product.currency.description })?.currenciesList else {
            return []
        }
        
        return currencies
    }
    
    func reduceFilterCurrencies(filterCurrencies: String?) -> [Currency] {
        
        var deliveryCurrencyProduct: [Payments.ParameterAmount.DeliveryCurrency]? = []
        
        if var splittedCurrency = filterCurrencies?.components(separatedBy: ";") {
            
            splittedCurrency.remove(at: 0)
            
            for currency in splittedCurrency {
                
                if let currency = self.deliveryCurrencyMapping(dataType: currency) {
                    
                    deliveryCurrencyProduct?.append(currency)
                }
            }
            
            if let filterCurrency = deliveryCurrencyProduct?.compactMap({ $0.selectedCurrency }) {
                
                return filterCurrency
            } else {
                
                return []
            }
            
        } else {
            
            return []
        }
    }
    
    func deliveryCurrencyMapping(dataType: String) -> Payments.ParameterAmount.DeliveryCurrency? {
        
        let splitCurrency = dataType.components(separatedBy: "=")
        
        let currincies = splitCurrency[1].components(separatedBy: ",").map({ Currency(description: $0.description)})
        
        if let firstCurriency = splitCurrency.first {
            
            let selectedCurrency = Currency(description: firstCurriency)
            return Payments.ParameterAmount.DeliveryCurrency(selectedCurrency: selectedCurrency, currenciesList: currincies)
            
        } else {
            
            return nil
        }
    }
}

extension Model {
    
    func templateHeader(
        templates: [PaymentTemplateData],
        source: Payments.Operation.Source
        ) -> Payments.ParameterHeader? {
            
        if case let .template(templateId) = source,
            let template = templates.first(where: { $0.id == templateId }) {
            
            return Payments.ParameterHeader(title: template.name,
                                                       rightButton: [.init(icon: .init(named: "ic24Edit2") ?? .iconPlaceholder,
                                                                           action: .editName(
                                                                            .init(oldName: template.name,
                                                                                  templateID: templateId)))])
        } else {
                
            return nil
        }
    }
}
