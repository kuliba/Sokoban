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
                
            var (country, optionID): (String?, String?) = try getCountyAndOptionId(source, operation)
                
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
                    style: .large
                )
            )
            
            let dropDownListId = Payments.Parameter.Identifier.countryDropDownList.rawValue
            
            var options: [Payments.ParameterSelectDropDownList.Option] = getOptions(countryWithService, operatorsList)
            
            guard let defaultService = optionID ?? options.first?.id,
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
            
            let productId = productWithSource(source: operation.source, productId: String(product.id))
            let productParameter = Payments.ParameterProduct(value: productId, filter: filter, isEditable: true)
            
            switch source {
            case .latestPayment:
                let dropDownListParameter = Payments.ParameterSelectDropDownList(.init(
                    id: dropDownListId,
                    value: defaultService
                ), title: titleDropDownList(operation), options: options)
                
                return .init(
                    parameters: [
                        operatorParameter,
                        headerParameter,
                        dropDownListParameter,
                        countryParameter,
                        productParameter
                    ],
                    front: .init(
                        visible: [
                            headerParameter.id,
                            dropDownListId,
                            countryId
                        ],
                        isCompleted: true
                    ),
                    back: .init(
                        stage: .remote(.start),
                        required: [
                            dropDownListId,
                            countryId
                        ],
                        processed: nil
                    )
                )
                
            default:
                
                if countryWithService?.servicesList.first(where: { $0.isDefault == true }) != nil {
                    
                    let option = countryWithService?.servicesList.first(where: { $0.isDefault == true })?.code.rawValue
                    
                    let dropDownListParameter = Payments.ParameterSelectDropDownList(.init(
                        id: dropDownListId,
                        value: option
                    ), title: titleDropDownList(operation), options: options)
                    
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
                    
                    let dropDownListParameter = Payments.ParameterSelectDropDownList(.init(
                        id: dropDownListId,
                        value: defaultService
                    ), title: titleDropDownList(operation), options: options)
                    
                    return .init(
                        parameters: [
                            operatorParameter,
                            headerParameter,
                            dropDownListParameter,
                            countryParameter,
                            productParameter
                        ],
                        front: .init(
                            visible: [
                                headerParameter.id,
                                dropDownListId,
                                countryId
                            ],
                            isCompleted: true
                        ),
                        back: .init(
                            stage: .remote(.start),
                            required: [
                                dropDownListId,
                                countryId
                            ],
                            processed: nil
                        )
                    )
                }
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
            
            guard let service = parameters.first(where: { $0.id == dropDownListId }) as? Payments.ParameterSelectDropDownList,
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
            
            let dropDownListParameter = Payments.ParameterSelectDropDownList.init(.init(
                id: service.id,
                value: options.first?.id
            ), title: titleDropDownList(operation), options: options)
            
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
            
            if let filterCurrencies = try? parameters.parameter(forIdentifier: .countryCurrencyFilter),
               let splitCurrencies = filterCurrencies.value?.components(separatedBy: ";"),
               splitCurrencies.count > 1 {
                
                let currenciesList = self.reduceDeliveryCurrency(productId: productId, splitCurrencies: splitCurrencies)
                let selectedCurrency = currenciesList.contains(where: { $0.description == amountParameter.deliveryCurrency?.selectedCurrency.description }) ? amountParameter.deliveryCurrency?.selectedCurrency : currenciesList.first
                
                let updatedAmountParameter = amountParameter.updated(value: amountParameter.value, deliveryCurrency: .init(selectedCurrency: selectedCurrency ?? .rub, currenciesList: currenciesList))
                
                guard let amountParameter = updatedAmountParameter as? Payments.ParameterAmount else {
                    return nil
                }

                return amountParameter.updated(currencySymbol: currencySymbol, maxAmount: maxAmount)
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
                ProductData.Filter.CardAdditionalSelfRule(),
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
                        
                        list.append(Payments.ParameterSelectBank.Option(id: item.id, name: item.name, subtitle: nil, icon: icon, isFavorite: false, searchValue: item.name))
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
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: phone), title: parameterData.title, placeholder: parameterData.subTitle, countryCode: .russian)
                    return phoneParameter
                    
                } else {
                    
                    // TODO: Create Model mock for testing
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: nil), title: parameterData.title, placeholder: parameterData.subTitle)
                    return phoneParameter
                }
                
            case Payments.Parameter.Identifier.countrybPhone.rawValue:
                let phoneId = Payments.Parameter.Identifier.countrybPhone.rawValue
                if case let .direct(phone: phone, countryId: _, serviceData: _) = operation.source {
                    
                    let phoneParameter = Payments.ParameterInputPhone(.init(id: phoneId, value: phone), title: parameterData.title, placeholder: parameterData.subTitle, countryCode: .russian)
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
                icon: .image(parameterData.iconData ?? .parameterLocation),
                title: parameterData.title, group: .init(id: "info", type: .info))
            
        case .selectSwitch:
            return nil
        }
    }
    
    func paymentsProcessRemoteStepAbroad(
        operation: Payments.Operation,
        response: TransferResponseData
    ) async throws -> Payments.Operation.Step {
        
        var parameters = RemoteStepAbroadParametersMapper.map(
            response,
            with: operation,
            and: self
        )
        
        let remoteStage: Payments.Operation.Stage.Remote = response.needOTP == true ? .confirm : .next
        
        let dividendParameter = try? parameters.parameter(forIdentifier: .countryDividend)
        
        if response.scenario == .suspect {
            
            parameters.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "SUSPECT"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
        }
        
        return .init(
            parameters: parameters,
            front: .init(
                visible: parameters.map(\.id),
                isCompleted: false
            ),
            back: .init(
                stage: .remote(remoteStage),
                required: [dividendParameter].compactMap(\.?.id),
                processed: nil
            )
        )
    }
        
    func paymentsProcessAbroadComplete(code: String, operation: Payments.Operation) async throws -> Payments.Success {
        
        let response = try await paymentsTransferComplete(
            code: code
        )
        
        let success = try Payments.Success(
            with: response,
            operation: operation
        )
        
        return success
    }
    
    func paymentsProcessOperationResetVisibleCountry(_ operation: Payments.Operation) -> [Payments.Parameter.ID]? {
        
        let restrictedIds = [Payments.Parameter.Identifier.countryId.rawValue,
                             Payments.Parameter.Identifier.countryCity.rawValue,
                             Payments.Parameter.Identifier.trnPickupPoint.rawValue]
        
        // check if current step stage is confirm
        guard operation.isConfirmCurrentStage else {
            
            let parameters = operation.steps.map(\.front.visible).flatMap({ $0 })
            
            let restrictedParameters = parameters.filter({ !restrictedIds.contains($0) })
            return restrictedParameters
        }
        
        let countrySwitch = Payments.Parameter.Identifier.countryDropDownList.rawValue
        if let bankParameter = operation.parameters.first(where: { $0.id == countrySwitch }),
           let value = bankParameter.value,
           let options = Payments.Operator.init(rawValue: value) {
            
            let identifiers: [Payments.Parameter.Identifier]
            
            switch options {
            case .contact, .contactCash:
                
                identifiers = [
                    .header,
                    .countrySelect,
                    .countryPayee,
                    .product,
                    .countryTransferNumber,
                    .countryCurrencyAmount,
                    .fee,
                    .sfpAmount,
                    .code,
                    .countryOffer,
                    .countryDividend,
                ]
                
            case .direct:
                
                identifiers = [
                    .header,
                    .countryPhone,
                    .countryBank,
                    .product,
                    .countryPayee,
                    .countryTransferNumber,
                    .countryCurrencyAmount,
                    .fee,
                    .countryPayeeAmount,
                    .sfpAmount,
                    .code,
                    .countryDividend
                ]
                
            default:
                
                identifiers = [
                    .header,
                    .countrySelect,
                    .countryPayee,
                    .product,
                    .countryTransferNumber,
                    .countryCurrencyAmount,
                    .fee,
                    .sfpAmount,
                    .code,
                    .countryDividend
                ]
            }
            
            return identifiers.map(\.rawValue)
        }
        
        let identifiers: [Payments.Parameter.Identifier] = [
            .header,
            .countrySelect,
            .countryPayee,
            .product,
            .countryTransferNumber,
            .countryCurrencyAmount,
            .fee,
            .sfpAmount,
            .code,
        ]
        
        return identifiers.map(\.rawValue)
    }
    
    private func getCountyAndOptionId(
        _ source: Payments.Operation.Source,
        _ operation: Payments.Operation
    ) throws -> (country: String?, optionID: String?) {
        
        switch source {
        case let .direct(countryId: countryId):
            let country = countryId.countryId.description
            return (country, nil)

        case let .template(templateId):
            
            let template = self.paymentTemplates.value.first(where: { $0.id == templateId })
            
            guard let list = template?.parameterList as? [TransferAnywayData],
                  let additional = list.last?.additional else {
                throw Payments.Error.missingSource(operation.service)
            }
            
            let country = additional.first(where: {
                $0.fieldname == Payments.Parameter.Identifier.countrySelect.rawValue
            })?.fieldvalue
            
            return (country, nil)

        case let .latestPayment(latestPaymentId):
            guard let latestPayment = self.latestPayments.value.first(where: { $0.id == latestPaymentId }),
                  let latestPayment = latestPayment as? PaymentServiceData else {
                throw Payments.Error.missingSource(operation.service)
            }
            
            let country = latestPayment.additionalList.first(where: { $0.isCountry })?.fieldValue
            let optionID = latestPayment.puref

            return (country, optionID)
            
        default:
            throw Payments.Error.missingSource(operation.service)
        }
    }
    
    private func titleDropDownList(
        _ operation: Payments.Operation
    ) -> String {
        
        var (country, optionID): (String?, String?)

        switch operation.source {
        case let .direct(_, countryId: countryId,_):
            country = countryId.description
            
        case let .latestPayment(latestPaymentId):
            guard let latestPayment = self.latestPayments.value.first(where: { $0.id == latestPaymentId }),
                  let latestPayment = latestPayment as? PaymentServiceData else {
                return "Перевести"
            }
            
            country = latestPayment.additionalList.first(where: { $0.isCountry })?.fieldValue
            optionID = latestPayment.puref
            
        case let .template(templateId):
            let template = self.paymentTemplates.value.first(where: { $0.id == templateId })
            
            guard let list = template?.parameterList as? [TransferAnywayData],
                  let additional = list.last?.additional else {
                return "Перевести"
            }
            
            country = additional.first(where: { $0.fieldname == Payments.Parameter.Identifier.countrySelect.rawValue })?.fieldvalue
            
        default:
            country = nil
        }
        
        let countryWithService = countriesListWithSevice.value.first(where: {($0.code == country || $0.contactCode == country)})
        let operatorsList = self.dictionaryAnywayOperators()
        
        let options = getOptions(countryWithService, operatorsList)
        
        if let defaultService = optionID ?? options.first?.id,
           defaultService.description.contained(in: [
            Payments.Operator.contactCash.rawValue
        ]) {
            return "Способ выплаты"
        } else {
            return "Перевести"
        }
    }
    
    private func getOptions(
        _ countryWithService: CountryWithServiceData?,
        _ operatorsList: [OperatorGroupData.OperatorData]?
    ) -> [Payments.ParameterSelectDropDownList.Option] {

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
        
        return options
    }
}

private extension Payments.Operation {
    
    func abroadPaymentsOperator() -> Payments.Operator? {
       
        let countrySwitch = Payments.Parameter.Identifier.countryDropDownList.rawValue
        guard
            let bankParameter = parameters.first(where: { $0.id == countrySwitch }),
                let value = bankParameter.value
        else { return nil }
        
        return Payments.Operator(rawValue: value)
    }
}

private extension RemoteStepAbroadParametersMapper {
    
    static func map(
        _ response: TransferResponseData,
        with operation: Payments.Operation,
        and model: Model
    ) -> [PaymentsParameterRepresentable] {
        
        map(
            response,
            paymentsOperator: operation.abroadPaymentsOperator(),
            formattedAmount: {
                model.paymentsAmountFormatted(
                    amount: $0,
                    parameters: operation.parameters
                )
            },
            normalAmountFormatted: model.normalAmountFormatted
        )
    }
}

enum RemoteStepAbroadParametersMapper {
    
    static func map(
        _ response: TransferResponseData,
        paymentsOperator: Payments.Operator?,
        formattedAmount: @escaping (Double) -> String?,
        normalAmountFormatted: @escaping (Double, String) -> String?
    ) -> [PaymentsParameterRepresentable] {
        
        var parameters1 = [PaymentsParameterRepresentable?]()
        
        if let paymentsOperator {
            
            switch paymentsOperator {
            case .direct, .cardKZ, .cardTJ, .cardUZ, .cardHumoUZ:
                
                parameters1.append(contentsOf: [
                    response.countryTransferNumber(
                        group: .init(id: "confirm", type: .info)
                    ),
                    response.amountParameter(
                        formatted: normalAmountFormatted
                    )
                ])
                
            default:
                
                parameters1.append(contentsOf: [
                    response.countryTransferNumber(),
                    response.creditAmountParameter(
                        formatted: normalAmountFormatted
                    )
                ])
            }
        }
        
        let parameters2: [PaymentsParameterRepresentable?] = [
            
            response.creditAmountParameter(
                formatted: normalAmountFormatted,
                amountIdentifier: .countryPayeeAmount,
                icon: .local("ic24User"),
                title: "Сумма зачисления в валюте"
            ),
            response.countryOffer(),
            response.debitAmountParameter(
                formatted: formattedAmount
            ),
            response.countryTransferReferenceNumber(),
            response.feeParameter(
                formatted: formattedAmount
            ),
            response.otpParameter(),
            response.dividend(),
        ]
        
        let parameters = (parameters1 + parameters2).compactMap { $0 }
        
        return parameters
    }
}

private extension TransferResponseData {
    
    func countryTransferNumber(
        group: Payments.Parameter.Group? = nil
    ) -> Payments.ParameterInfo? {
        
        payeeName.map { customerName in
            
            let countryTransferNumberId = Payments.Parameter.Identifier.countryPayee.rawValue
            
            return .init(
                .init(
                    id: countryTransferNumberId,
                    value: customerName
                ),
                icon: .local("ic24User"),
                title: "Получатель",
                placement: .feed,
                group: group
            )
        }
    }
    
    func countryTransferReferenceNumber(
    ) -> Payments.ParameterInfo? {
        
        guard
            let response = self as? TransferAnywayResponseData,
            let trnReference = response.additionalList.first(where: { $0.fieldName == "trnReference" })
        else { return nil }
        
        let countryTransferNumberId = Payments.Parameter.Identifier.countryTransferNumber.rawValue
        
        return .init(
            .init(
                id: countryTransferNumberId,
                value: trnReference.fieldValue
            ),
            icon: .local("ic24PercentCommission"),
            title: trnReference.fieldTitle ?? "Номер перевода",
            placement: .feed,
            group: .init(
                id: "confirm", type: .info
            )
        )
    }
    
    func amountParameter(
        formatted: @escaping (Double, String) -> String?
    ) -> Payments.ParameterInfo? {
        
        guard
            let amountValue = amount,
            let currencyPayer = currencyPayer
        else { return nil }
        
        let amount = formatted(amountValue, currencyPayer.description)
        
        let amountParameterId = Payments.Parameter.Identifier.countryCurrencyAmount.rawValue
        
        return .init(
            .init(id: amountParameterId, value: amount),
            icon: .local("ic24Coins"),
            title: "Сумма перевода",
            placement: .feed,
            group: .init(
                id: "confirm",
                type: .info
            )
        )
    }
    
    func debitAmountParameter(
        formatted: @escaping (Double) -> String?
    ) -> Payments.ParameterInfo? {
        
        guard
            let amountCurrency = debitAmount,
            let amountFormatted = formatted(amountCurrency)
        else { return nil }
        
        let amountParameterId = Payments.Parameter.Identifier.sfpAmount.rawValue
        
        return .init(
            .init(
                id: amountParameterId,
                value: amountFormatted
            ),
            icon: .local("ic24Coins"),
            title: "Сумма списания",
            placement: .feed,
            group: .init(
                id: "confirm",
                type: .info
            )
        )
    }
    
    func creditAmountParameter(
        formatted: @escaping (Double, String) -> String?,
        amountIdentifier: Payments.Parameter.Identifier = .countryCurrencyAmount,
        icon: Payments.Parameter.Icon = .local("ic24Coins"),
        title: String = "Сумма перевода"
    ) -> Payments.ParameterInfo? {
        
        guard
            let amountValue = creditAmount,
            let currencyPayee = currencyPayee
        else { return nil }
        
        let amount = formatted(amountValue, currencyPayee.description)
        
        return .init(
            .init(
                id: amountIdentifier.rawValue,
                value: amount
            ),
            icon: icon,
            title: title,
            placement: .feed,
            group: .init(
                id: "confirm",
                type: .info
            )
        )
    }
    
    func countryOffer() -> Payments.ParameterCheck? {
        
        guard
            let response = self as? TransferAnywayResponseData,
            let oferta = response.additionalList.first(where: { $0.fieldName == "oferta" }),
            let title = oferta.fieldTitle,
            let urlString = oferta.fieldValue
        else { return nil }
        
        let countryOferta = Payments.Parameter.Identifier.countryOffer.rawValue
        
        return .init(
            .init(id: countryOferta, value: "true"),
            title: title,
            urlString: urlString,
            style: .c2bSubscription,
            mode: .abroad
        )
    }
    
    func dividend() -> Payments.ParameterCheck? {
        
        guard
            let response = self as? TransferAnywayResponseData,
            let dividend = response.additionalList.first(where: {
                $0.typeIdParameterList == "checkbox"
                && $0.fieldName == "dividend"
            }),
            let title = dividend.fieldTitle
        else { return nil }
        
        let countryDividend = Payments.Parameter.Identifier.countryDividend.rawValue
        
        return .init(
            .init(id: countryDividend, value: "true"),
            title: title,
            urlString: dividend.fieldValue,
            style: .c2bSubscription,
            mode: .normal
        )
    }
    
    func feeParameter(
        formatted: @escaping (Double) -> String?
    ) -> Payments.ParameterInfo? {
        
        guard
            let feeAmount = fee,
            let feeAmountFormatted = formatted(feeAmount)
        else { return nil }
        
        let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
        
        return .init(
            .init(
                id: feeParameterId,
                value: feeAmountFormatted
            ),
            icon: .local("ic24PercentCommission"),
            title: "Комиссия",
            placement: .feed,
            group: .init(
                id: "confirm",
                type: .info
            )
        )
    }
    
    func otpParameter() -> Payments.ParameterCode? {
        
        needOTP == true ? .regular : nil
    }
}

extension Model {
    
    func reduceDeliveryCurrency(productId: ProductData.ID, splitCurrencies: [String]) -> [Currency] {
        
        var clearCurrency = splitCurrencies
        clearCurrency.remove(at: 0)
        
        let deliveryCurrency = clearCurrency.compactMap(deliveryCurrencyMapping(dataType:))
        
        guard let product = self.product(productId: productId),
              let currencies = deliveryCurrency.first(where: { $0.selectedCurrency.description == product.currency.description })?.currenciesList
        else { return [] }
        
        return currencies
    }
    
    func reduceFilterCurrencies(filterCurrencies: String?) -> [Currency] {
        
        guard var splitCurrencies = filterCurrencies?.components(separatedBy: ";")
        else { return [] }
        
        splitCurrencies.remove(at: 0)
        
        return splitCurrencies
            .compactMap(deliveryCurrencyMapping(dataType:))
            .compactMap({ $0.selectedCurrency })
    }
    
    func deliveryCurrencyMapping(dataType: String) -> Payments.ParameterAmount.DeliveryCurrency? {
        
        let splitCurrency = dataType.components(separatedBy: "=")
        
        let currencies = splitCurrency[1]
            .components(separatedBy: ",")
            .map(\.description)
            .map(Currency.init(description:))
        
        return splitCurrency.first.map { firstCurrency in
            
            let selectedCurrency = Currency(description: firstCurrency)
            return .init(selectedCurrency: selectedCurrency, currenciesList: currencies)
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
            
            return Payments.ParameterHeader(
                title: template.name,
                rightButton: [
                    .init(
                        icon: .init(named: "ic24Edit2") ?? .iconPlaceholder,
                        action: .editName(
                            .init(oldName: template.name,
                                  templateID: templateId)))
                ])
        } else {
                
            return nil
        }
    }
}
