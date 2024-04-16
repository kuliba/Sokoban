//
//  BusinessLogic.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 23.10.2023.
//

import Foundation
import Combine
import GenericRemoteService

final public class BusinessLogic {
    
    public typealias DictionaryCompletion = (Result<StickerDictionary, StickerDictionaryError>) -> Void
    public typealias ProcessDictionaryService = (GetJsonAbroadType, @escaping DictionaryCompletion) -> ()
    
    public typealias TransferCompletion = (Result<CommissionProductTransfer, CommissionProductTransferError>) -> Void
    public typealias ProcessTransferService = (StickerPayment, @escaping TransferCompletion) -> ()
    
    public typealias MakeTransferCompletion = (Result<MakeTransferResponse, MakeTransferError>) -> Void
    public typealias ProcessMakeTransferService = (String, @escaping MakeTransferCompletion) -> ()
    
    public typealias ImageLoaderCompletion = (Result<[ImageData], GetImageListError>) -> Void
    public typealias ProcessImageLoaderService = ([String], @escaping ImageLoaderCompletion) -> ()
    
    public typealias Product = Operation.Parameter.ProductSelector.Product
    public typealias OperationResult = Result<OperationStateViewModel.State, Error>
    
    public typealias SelectOffice = (Location, @escaping (Office?) -> Void) -> Void
    
    let processDictionaryService: ProcessDictionaryService
    let processTransferService: ProcessTransferService
    let processMakeTransferService: ProcessMakeTransferService
    let processImageLoaderService: ProcessImageLoaderService
    let selectOffice: SelectOffice
    let products: () -> [Product]
    let cityList: (TransferType) -> [City]
    
    public init(
        processDictionaryService: @escaping ProcessDictionaryService,
        processTransferService: @escaping ProcessTransferService,
        processMakeTransferService: @escaping ProcessMakeTransferService,
        processImageLoaderService: @escaping ProcessImageLoaderService,
        selectOffice: @escaping SelectOffice,
        products: @escaping () -> [Product],
        cityList: @escaping (TransferType) -> [City]
    ) {
        self.processDictionaryService = processDictionaryService
        self.processTransferService = processTransferService
        self.processMakeTransferService = processMakeTransferService
        self.processImageLoaderService = processImageLoaderService
        self.selectOffice = selectOffice
        self.products = products
        self.cityList = cityList
    }
}

public extension BusinessLogic {
    
    func process(
        operation: PaymentSticker.Operation,
        event: Event,
        completion: @escaping (OperationResult) -> Void
    ) {
        
        switch event {
        case let .select(selectEvent):
            
            switch selectEvent {
            case let .search(text, parameter):
                let result = reduceSearchAction(operation, text, parameter)
                completion(result)
                
            case let .selectOption(id, parameter):
                
                let operation = selectOption(
                    id: id.name,
                    operation: operation,
                    parameter: parameter
                )
                
                switch parameter.id {
                case .transferTypeSticker:
                    switch id.name {
                    case "Получить в офисе":
                        
                        deliveryOffice(operation, completion)
                        completion(.success(.operation(operation)))
                        
                    case "Доставка курьером":
                        
                        deliveryCourier(operation, completion)
                        completion(.success(.operation(operation)))
                        
                    default:
                        break
                    }
                    
                case .citySelector:
                    citySelector(id, operation, parameter, completion)
                    
                case .selector:
                    completion(.success(.operation(operation)))
                    
                case .officeSelector:
                    completion(.success(.operation(operation)))
                }
                
                break
                
            case let .openBranch(location):
                
                let location = Location(id: location.id)
                
                if location.id != "" {
                    
                    selectOffice(location) { result in
                        
                        switch result {
                        case let .some(office):
                            
                            let parametersWithInput = operation.parameters
                                .filter { $0.id == .input }
                            
                            if parametersWithInput.isEmpty {

                                let newOperation = operation.updateOperation(
                                    operation: operation,
                                    newParameter: .select(.officeSelect(office: office))
                                )
                                
                                completion(.success(.operation(newOperation)))
                                
                            } else {
                                
                                let newOperation = operation.updateOperation(
                                    operation: operation,
                                    newParameter: .select(.officeSelect(office: office))
                                )
                                
                                let parameters = newOperation.parameters
                                    .filter { $0.id != .amount && $0.id != .input }
                                
                                completion(.success(.operation(.init(parameters: parameters))))
                            
                            }
                            
                        case .none:
                            completion(.success(.operation(operation)))
                        }
                    }
                }
                completion(.success(.operation(operation)))

            case let .chevronTapped(select):
                completion(resultChevronTapped(select, operation))
            }
            
        case let .input(events):
            switch events {
            case .getCode:
                completion(.success(.operation(operation)))
                
            case let .valueUpdate(value):
                
                let parametersUpdate = operation.updateOperation(
                    operation: operation,
                    newParameter: .input(.init(
                        value: value,
                        title: .code,
                        warning: nil
                    ))
                )
                completion(.success(.operation(parametersUpdate)))
            }
            
        case .continueButtonTapped:
            
            switch operation.operationStage {
            case .start:
                
                processDictionaryService(.stickerOrderForm) { result in
                    
                    switch result {
                    case let .success(dictionaryResponse):
                        
                        let state = self.dictionaryStickerReduce(
                            operation, dictionaryResponse
                        )
                        switch state {
                        case let .operation(operation):
                            switch dictionaryResponse {
                            case let .orderForm(sticker):
                                
                                switch sticker.main.first(where: { $0.type == .productInfo })?.data {
                                case let .banner(banner):
                                    
                                    self.imageLoader(operation: operation, banner: banner) { result in
                                        
                                        switch result {
                                        case let .success(state):
                                            completion(.success(state))
                                            
                                        case let .failure(error):
                                            completion(.failure(error))
                                        }
                                    }
                                    
                                default:
                                    completion(.success(.operation(operation)))
                                }
                            default:
                               break
                            }
                        case .result:
                            return
                        }
                    case .failure(_):
                        break
                    }
                }
                
                completion(.success(.operation(.init(
                    state: .process,
                    parameters: operation.parameters
                ))))
                
            case .process:
                    
                let stickerPayment = getStickerPayment(
                    parameters: operation.parameters
                )
                
                processTransferService(stickerPayment) { result in
                    
                    switch result {
                    case let .success(success):
                        
                        var newOperation = operation
                        newOperation = newOperation.updateOperation(
                            operation: newOperation,
                            newParameter: .input(.init(
                                value: "",
                                title: .code,
                                warning: nil
                            ))
                        )
                        
                        newOperation = newOperation.updateOperation(
                            operation: newOperation,
                            newParameter: .amount(.init(value: success.amount.description))
                        )
                        
                        completion(.success(.operation(newOperation)))
                        
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
                
                completion(.success(.operation(.init(
                    state: .process,
                    parameters: operation.parameters
                ))))
                
            case .code:
                if let input = operation.inputParameter {
                    
                    switch input {
                    case let .input(input):
                        
                        processMakeTransferService(input.value) { result in
                            
                            switch result {
                            case let .success(makeTransfer):
                                completion(.success(.result(
                                    PaymentSticker.OperationResult(
                                        result: .success,
                                        title: "Успешная заявка",
                                        description: makeTransfer.productOrderingResponseMessage,
                                        amount: operation.parameters.amountSticker ?? "",
                                        paymentID: .init(id: makeTransfer.paymentOperationDetailId)
                                    )))
                                )
                                
                            case let .failure(error):
                                
                                if case let .error(_, errorMessage) = error {
                                    
                                    let newOperation = operation.updateOperation(
                                        operation: operation,
                                        newParameter: .input(.init(
                                            value: "",
                                            title: .code,
                                            warning: errorMessage
                                        ))
                                    )
                                    completion(.success(.operation(newOperation)))
                                    
                                }
                            }
                        }
                        
                        let amount =  operation.parameters.first(where: { $0.id == .amount })
                        
                        switch amount {
                        case let .amount(amount):
                            
                            let newOperation = operation.updateOperation(
                                operation: operation,
                                newParameter: .amount(.init(
                                    state: .loading,
                                    value: amount.value
                                ))
                            )
                            
                            completion(.success(.operation(.init(
                                state: .process,
                                parameters: newOperation.parameters
                            ))))
                            
                        default:
                            completion(.success(.operation(operation)))
                        }
                        
                    default:
                        completion(.success(.operation(operation)))
                    }
                }
            }

        case let .product(productEvents):
            completion(reduceProductEvent(productEvents, operation))
        }
    }
    
    func getStickerPayment(parameters: [Operation.Parameter]) -> StickerPayment {
    
        .init(
            currencyAmount: "RUB",
            amount: parameters.deliveryToOffice == true ? 790 : 1500,
            check: false,
            payer: .init(cardId: parameters.productID ?? ""),
            productToOrderInfo: .init(
                type: "STICKER",
                deliverToOffice: parameters.deliveryToOffice ?? false,
                officeId: parameters.officeID,
                cityId: parameters.deliveryToOffice == true ? nil : parameters.cityID
            ))
    }
    
    func reduceProductEvent(
        _ productEvents: (Event.ProductEvent),
        _ operation: PaymentSticker.Operation
    ) -> BusinessLogic.OperationResult {
        
        switch productEvents {
        case let .chevronTapped(product, state):
            let newOperation = operation.updateOperation(
                operation: operation,
                newParameter: .productSelector(.init(
                    state: state,
                    selectedProduct: product.selectedProduct,
                    allProducts: product.allProducts
                ))
            )
            return .success(.operation(newOperation))
            
        case let .selectProduct(option, product):
            
            if operation.parameters.first(where: { $0.id == .input }) != nil {
                
                let parameters = operation.parameters.filter({ $0.id != .input }).filter({ $0.id != .amount })
                return .success(.operation(.init(parameters: parameters)))
                
            } else {
             
                if let option {

                    let operation = operation.updateOperation(
                        operation: operation,
                        newParameter: .productSelector(.init(
                            state: .select,
                            selectedProduct: option,
                            allProducts: product.allProducts))
                    )
                    
                    return .success(.operation(operation))
                } else {
                    
                    return .success(.operation(operation))
                }
            }
        }
    }
    
    fileprivate func citySelector(
        _ id: Event.SelectOptionID,
        _ operation: Operation,
        _ parameter: Event.ParameterSelect,
        _ completion: (BusinessLogic.OperationResult) -> Void
    ) {
        if operation.parameters.first(where: { $0.id == .input }) != nil {
            
            let parameters = operation.parameters.filter({ 
                ($0.id != .input &&  $0.id != .amount)
            })
            
            let newOperation = Operation(parameters: parameters)
            let updateOperation = newOperation.updateOperation(
                operation: newOperation,
                newParameter: .select(.branchSelect)
            )
            
            completion(.success(.operation(updateOperation)))
            
        } else {
            
            let newOperation = operation.updateOperation(
                operation: operation,
                newParameter: .select(parameter)
            )
            
            if let transferType = operation.parameters.first(where: { $0.id == .transferType }) {
                
                switch transferType {
                case let .select(select):
                    if select.value == "typeDeliveryOffice" {
                        
                        let filterOperation = newOperation.updateOperation(
                            operation: newOperation,
                            newParameter: .select(.branchSelect)
                        )
                        
                        let operation = selectOption(
                            id: id.name,
                            operation: filterOperation,
                            parameter: parameter
                        )
                        
                        completion(.success(.operation(operation)))
                        
                    } else {
                        
                        let operation = selectOption(
                            id: id.name,
                            operation: newOperation,
                            parameter: parameter
                        )
                        
                        completion(.success(.operation(operation)))
                    }
                    
                default:
                    completion(.success(.operation(newOperation)))
                }
            }
        }
    }
    
    fileprivate func deliveryCourier(
        _ operation: Operation,
        _ completion: @escaping (BusinessLogic.OperationResult) -> Void
    ) {
        processDictionaryService(.stickerOrderDeliveryCourier) { [weak self] result in
            
            switch result {
            case let .success(dictionaryResponse):
                
                let state = self?.dictionaryStickerReduce(
                    operation,
                    dictionaryResponse
                )
                
                if operation.parameters.contains(where: { $0.id == .input }) {
                    
                    switch state {
                    case let .operation(operation):
                        
                        let operationBack = operation.parameters.filter({ $0.id != .input })
                        completion(.success(.operation(.init(parameters: operationBack))))
                        
                    default:
                        
                        completion(.success(self?.dictionaryStickerReduce(
                            operation,
                            dictionaryResponse
                        ) ?? .operation(operation)))
                    }
                }
                
                completion(.success(state ?? .operation(operation)))
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    fileprivate func deliveryOffice(
        _ operation: Operation,
        _ completion: @escaping (BusinessLogic.OperationResult) -> Void
    ) {
        
        processDictionaryService(.stickerOrderDeliveryOffice) { result in

            switch result {
            case let .success(dictionaryResponse):
                let state = self.dictionaryStickerReduce(
                    operation,
                    dictionaryResponse
                )
                
                if operation.parameters.contains(where: { $0.id == .input }) {
                    
                    switch state {
                    case let .operation(operation):
                        
                        let operationBack = operation.parameters.filter({ $0.id != .input })
                        completion(.success(.operation(.init(parameters: operationBack))))
                        
                    default:
                        
                        completion(.success(self.dictionaryStickerReduce(
                            operation,
                            dictionaryResponse
                        )))
                    }
                }
                
                completion(.success(state))
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func selectOption(
        id: String,
        operation: PaymentSticker.Operation,
        parameter: PaymentSticker.Operation.Parameter.Select
    ) -> PaymentSticker.Operation {
        
        guard let option = parameter.options.first(where: { $0.name == id })
        else { return operation }
        
        let parameter = parameter.updateValue(
            parameter: parameter,
            option: option
        )
        
        let updateParameter = parameter.updateValue(
            parameter: parameter,
            option: option
        )
        
        return operation.updateOperation(
            operation: operation,
            newParameter: .select(updateParameter)
        )
    }
    
    func dictionaryStickerReduce(
        _ operation: PaymentSticker.Operation,
        _ dictionaryResponse: StickerDictionary
    ) -> OperationStateViewModel.State {
        
        switch dictionaryResponse {
        case let .orderForm(orderForm):
            
            let parameters = orderForm.main.map { main in
                
                switch main.data {
                case let .citySelector(citySelector):
                    return Operation.Parameter.select(.init(
                        id: .citySelector,
                        value: "",
                        title: citySelector.title,
                        placeholder: citySelector.subtitle,
                        options: [],
                        staticOptions: [],
                        state: .idle(.init(iconName: "", title: citySelector.title)))
                    )
                    
                case let .banner(banner):
                    return .sticker(.init(
                        title: banner.title,
                        description: banner.subtitle,
                        image: PaymentSticker.ImageData.named(""),
                        options: banner.txtConditionList.map({
                            
                            Operation.Parameter.Sticker.PriceOption(
                                title: $0.name,
                                price: $0.value,
                                description: "\($0.description) \($0.value)")
                        })
                    ))
                    
                case let .officeSelector(officeSelector):
                    return .select(.init(
                        id: .officeSelector,
                        value: "",
                        title: officeSelector.title,
                        placeholder: officeSelector.subtitle,
                        options: [],
                        staticOptions: [],
                        state: .idle(.init(iconName: "", title: officeSelector.title)))
                    )
                    
                case .product:
                    if let product = self.products().first {
                        
                        return .productSelector(.init(
                            state: .select,
                            selectedProduct: product,
                            allProducts: self.products()
                        ))
                    } else {
                        
                        return nil
                    }
                    
                case let .selector(selector):
                    return .select(.init(
                        id: .transferTypeSticker,
                        value: nil,
                        title: selector.title,
                        placeholder: selector.subtitle,
                        options: selector.list.map({
                            Operation.Parameter.Select.Option(
                                id: $0.type.rawValue,
                                name: $0.title,
                                iconName: ""
                            )
                        }),
                        staticOptions: selector.list.map({
                            Operation.Parameter.Select.Option(
                                id: $0.type.rawValue,
                                name: $0.title,
                                iconName: ""
                            )
                        }),
                        state: .idle(.init(iconName: "", title: selector.title)))
                    )
                    
                case let .hint(hint):
                    return .tip(.init(title: hint.title))
                    
                default: return nil
                }
                
            }.compactMap{ $0 }
            
            return .operation(.init(parameters: parameters))
            
        case let .deliveryType(deliveryType):
            
            let parameters = deliveryType.main.map { main in
                
                switch main.data {
                case let .citySelector(citySelector):
                    
                    let transferType = operation.parameters.getParameterTransferType()
                    
                    if transferType?.value == "typeDeliveryOffice" {
                        
                        return Operation.Parameter.select(.init(
                            id: .citySelector,
                            value: nil,
                            title: citySelector.title,
                            placeholder: citySelector.subtitle,
                            options: self.cityList(.office).map({ Operation.Parameter.Select.Option(
                                id: $0.id,
                                name: $0.name,
                                iconName: ""
                            )}),
                            staticOptions: self.cityList(.office).map({ Operation.Parameter.Select.Option(
                                id: $0.id,
                                name: $0.name,
                                iconName: ""
                            )}),
                            state: .idle(.init(iconName: "", title: citySelector.title)))
                        )
                        
                    } else {
                     
                        return Operation.Parameter.select(.init(
                            id: .citySelector,
                            value: nil,
                            title: citySelector.title,
                            placeholder: citySelector.subtitle,
                            options: self.cityList(.courier).map({ Operation.Parameter.Select.Option(
                                id: $0.id,
                                name: $0.name,
                                iconName: ""
                            )}),
                            staticOptions: self.cityList(.courier).map({ Operation.Parameter.Select.Option(
                                id: $0.id,
                                name: $0.name,
                                iconName: ""
                            )}),
                            state: .idle(.init(iconName: "", title: citySelector.title)))
                        )
                        
                    }
                    
                case let .officeSelector(officeSelector):
                    return Operation.Parameter.select(.init(
                        id: .officeSelector,
                        value: nil,
                        title: officeSelector.title,
                        placeholder: officeSelector.subtitle,
                        options: [],
                        staticOptions: [],
                        state: .idle(.init(iconName: "", title: officeSelector.title)))
                    )
                    
                default:
                    return nil
                }
            }.compactMap{ $0 }
            
            var newOperation: [PaymentSticker.Operation.Parameter] = []
            
            for parameter in operation.parameters {
                
                let availableParameter: [PaymentSticker.Operation.Parameter.ID] = [.tip, .sticker, .productSelector, .transferType]
                
                if availableParameter.contains(where: { $0.rawValue == parameter.id.rawValue }) {
                    
                    newOperation.append(parameter)
                }
            }
            
            for parameter in parameters {
                
                newOperation.append(parameter)
            }
            
            return .operation(.init(parameters: newOperation))
        }
    }
    
    func imageLoader(
        operation: PaymentSticker.Operation,
        banner: StickerDictionary.Banner,
        completion: @escaping (OperationResult) -> Void
    ) {
        processImageLoaderService([banner.md5hash]) { result in
            
            switch result {
            case .success(_):
                
                let newOperation = operation.updateOperation(
                    operation: operation,
                    newParameter: .sticker(.init(
                        title: banner.title,
                        description: banner.subtitle,
                        image: .named("StickerPreview"),
                        options: banner.txtConditionList.map { item in
                            
                                .init(
                                    title: item.name,
                                    price: item.value,
                                    description: "\(item.value.description.dropLast(2)) ₽"
                                )
                        }
                    ))
                )
                
                completion(.success(.operation(newOperation)))
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension BusinessLogic {
    
    func reduceSearchAction(
        _ operation: Operation,
        _ text: String,
        _ parameter: Event.ParameterSelect
    ) -> BusinessLogic.OperationResult {
        
        let newOptions = parameter.staticOptions.filter({ $0.name.localizedCaseInsensitiveContains(text) })
        let newOperation: Operation = operation.updateOperation(
            operation: operation,
            newParameter: .select(.init(
                id: parameter.id,
                value: parameter.value,
                title: parameter.title,
                placeholder: parameter.placeholder,
                options: text != "" ? newOptions : parameter.staticOptions,
                staticOptions: parameter.staticOptions,
                state: parameter.state
            ))
        )
        
        return .success(.operation(newOperation))
    }
    
    func resultChevronTapped(
        _ select: (Event.ParameterSelect),
        _ operation: Operation
    ) -> BusinessLogic.OperationResult {
        
        switch select.state {
        case let .idle(idleViewModel):
            
            let updateSelect = select.updateSelect(
                parameter: select,
                idleViewModel: idleViewModel
            )
            
            return .success(.operation(operation.updateOperation(
                operation: operation,
                newParameter: .select(updateSelect)
            )))
            
        case let .selected(selectedViewModel):
            
            let parameter = select.updatingStateToList(
                iconName: selectedViewModel.iconName
            )
            
            return .success(.operation(operation.updateOperation(
                operation: operation,
                newParameter: .select(parameter)
            )))
            
        case let .list(listViewModel):
            
            if select.value != nil {
                
                let parameter = select.updatingStateToSelect(
                    iconName: listViewModel.iconName
                )
                
                return .success(.operation(operation.updateOperation(
                    operation: operation,
                    newParameter: .select(parameter)
                )))
                
            } else {
                let parameter = select.updatedStateToIdle(
                    iconName: listViewModel.iconName,
                    title: listViewModel.title
                )
                
                return .success(.operation(operation.updateOperation(
                    operation: operation,
                    newParameter: .select(parameter)
                )))
            }
        }
    }
}

// MARK: - Types

extension BusinessLogic {
    
    public struct City {
        
        let id: String
        let name: String
        
        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    public enum TransferType {
        
        case office
        case courier
    }
}

// MARK: Helpers

extension Operation {

    var inputParameter: Operation.Parameter? {
        
        self.parameters.first(where: { $0.id == .input })
    }
}

extension PaymentSticker.ParameterViewModel {
    
    var inputTitle: String? {
        
        guard case let .input(_, title, _) = self else {
            return nil
        }
        
        return title
    }
}

