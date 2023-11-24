//
//  BusinessLogic.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 23.10.2023.
//

import Foundation
import Combine
import GenericRemoteService

public struct Location: Hashable, Identifiable {
    
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public struct Office {
    
    let id: String
    let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

final public class BusinessLogic {
    
    // TODO: simplify remote services error
    public typealias ProcessDictionaryService = (GetJsonAbroadType, @escaping (Result<StickerDictionary, StickerDictionaryError>) -> Void) -> ()
    public typealias ProcessTransferService = (StickerPayment, @escaping (Result<CommissionProductTransfer, CommissionProductTransferError>) -> Void) -> ()
    public typealias ProcessMakeTransferService = (String, @escaping (Result<MakeTransferResponse, MakeTransferError>) -> Void) -> ()
    public typealias ProcessImageLoaderService = ([String], @escaping (Result<[ImageData], GetImageListError>) -> Void) -> ()
    
    public typealias Product = Operation.Parameter.ProductSelector.Product
    public typealias OperationResult = Result<OperationStateViewModel.State, Error>
    
    public typealias SelectOffice = (Location, @escaping (Office?) -> Void) -> Void
    
    let processDictionaryService: ProcessDictionaryService
    let processTransferService: ProcessTransferService
    let processMakeTransferService: ProcessMakeTransferService
    let processImageLoaderService: ProcessImageLoaderService
    let selectOffice: SelectOffice
    let products: [Product]
    let cityList: [City]
    
    public init(
        processDictionaryService: @escaping ProcessDictionaryService,
        processTransferService: @escaping ProcessTransferService,
        processMakeTransferService: @escaping ProcessMakeTransferService,
        processImageLoaderService: @escaping ProcessImageLoaderService,
        selectOffice: @escaping SelectOffice,
        products: [Product],
        cityList: [City]
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
    
    func operationResult(
        operation: PaymentSticker.Operation,
        event: Event,
        completion: @escaping (OperationResult) -> Void
    ) {
        
        let result: OperationResult = process(
            operation: operation,
            event: event,
            completion: completion
        )
        
        completion(result)
    }
}

extension BusinessLogic {
    
    func process(
        operation: PaymentSticker.Operation,
        event: Event,
        completion: @escaping (OperationResult) -> Void
    ) -> OperationResult {
        
        switch event {
        case let .select(selectEvent):
            
            switch selectEvent {
            case let .selectOption(id, parameter):
                
                let operation = selectOption(
                    id: id.name,
                    operation: operation,
                    parameter: parameter
                )
                 
                if parameter.id == .officeSelector {
                
                    let newOperation = operation.updateOperation(
                        operation: operation,
                        newParameter: .select(parameter)
                    )
                    completion(.success(.operation(newOperation)))
                    return .success(.operation(newOperation))

                }
                
                switch parameter.id {
                case .transferTypeSticker:
                    
                    switch id.name {
                    case "Получить в офисе":
                        processDictionaryService(.stickerOrderDeliveryOffice) { result in
                            
                            switch result {
                            case let .success(dictionaryResponse):
                                completion(.success(self.dictionaryStickerReduce(
                                    operation,
                                    dictionaryResponse
                                )))
                                
                            case let .failure(error):
                                completion(.failure(error))
                            }
                        }

                    case "Доставка курьером":
                        processDictionaryService(.stickerOrderDeliveryCourier) { result in
                            
                            switch result {
                            case let .success(dictionaryResponse):
                                completion(.success(self.dictionaryStickerReduce(
                                    operation,
                                    dictionaryResponse
                                )))
                                
                            case let .failure(error):
                                completion(.failure(error))
                            }
                        }
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
                
                return .success(.operation(operation))
            
            case let .openBranch(location):
                
                let location = Location(id: location.id)
                selectOffice(location) { result in
                    
                    switch result {
                    case let .some(office):
                        
                        let newOperation = operation.updateOperation(
                            operation: operation,
                            newParameter: .select(.init(
                                id: .officeSelector,
                                value: office.id,
                                title: "Выберите отделение",
                                placeholder: "",
                                options: [],
                                state: .selected(.init(
                                    title: "Выберите отделение",
                                    placeholder: "",
                                    name: office.name,
                                    iconName: ""
                                )))))
                        
                        completion(.success(.operation(newOperation)))
                        
                    case .none:
                        completion(.success(.operation(operation)))
                    }
                }
                
                return .success(.operation(operation))

            case let .chevronTapped(select):
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
                    
                    let parameter = select.updatedState(
                        iconName: selectedViewModel.iconName
                    )
                    
                    return .success(.operation(operation.updateOperation(
                        operation: operation,
                        newParameter: .select(parameter)
                    )))
                    
                case let .list(listViewModel):
                    
                    let parameter = select.updatedState(
                        iconName: listViewModel.iconName,
                        title: listViewModel.title
                    )
                    
                    return .success(.operation(operation.updateOperation(
                        operation: operation,
                        newParameter: .select(parameter)
                    )))
                }
            }
        
        case let .input(events):
            switch events {
            case .getOtpCode:
                return .success(.operation(operation))

            case let .valueUpdate(input):
                guard let title = operation.parameters.inputTitle else {
                    // TODO: error missing input
                    struct MissingInputError: Error {}
                    return .failure(MissingInputError())
                }
                
                let parametersUpdate = operation.updateOperation(
                    operation: operation,
                    newParameter: .input(.init(
                        value: input,
                        title: title,
                        warning: nil
                    ))
                )
                return .success(.operation(parametersUpdate))
            }
            
        case .continueButtonTapped:
           
            if operation.parameters.count == 0 {
                
                processDictionaryService(.stickerOrderForm) { result in
                    
                    switch result {
                    case let .success(dictionaryResponse):
                        
                        let state = self.dictionaryStickerReduce(operation, dictionaryResponse)
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
                                    
                                default: break
                                }
                            default:
                                break
                            }
                        case .result:
                            return
                        }
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
                
                return .success(.operation(.init(state: .process, parameters: operation.parameters)))
                
            } else if let input = operation.parameters.first(where: { $0.id == .input }) {
                
                let amount = operation.parameters.amountSticker
                
                switch input {
                case let .input(input):
                    
                    processMakeTransferService(input.value) { result in
                       
                        switch result {
                        case let .success(makeTransfer):
                            completion(.success(.result(OperationStateViewModel.OperationResult(
                                result: .success,
                                title: "Успешная заявка",
                                description: makeTransfer.productOrderingResponseMessage,
                                amount: amount ?? "",
                                paymentID: .init(id: makeTransfer.paymentOperationDetailId)
                            ))))

                        case let .failure(error):
                            
                            if case let .error(_, errorMessage) = error {

                                let newOperation = operation.updateOperation(
                                    operation: operation,
                                    newParameter: .input(.init(
                                        value: "",
                                        title: "Введите код",
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
                        
                        return .success(.operation(.init(state: .process, parameters: newOperation.parameters)))
                    default:
                        return .success(.operation(.init(parameters: operation.parameters)))
                    }

                default:
                    return .success(.operation(operation))
                }
                
            } else {
             
                let productSelector = operation.parameters.first(where: {$0.id == .productSelector })
                
                var cardId: String? = nil
                
                switch productSelector {
                case let .productSelector(product):
                    cardId = product.selectedProduct.id.description
                default:
                    break
                }
                
                var deliverToOffice: Bool?
                var officeId: String?
                var cityId: Int?
                var amount: Decimal = 0
                
                let transferType = operation.parameters.first(where: { $0.id == .transferType })
                switch transferType {
                case let .select(select):
                    if select.value == "typeDeliveryOffice" {
                        deliverToOffice = true
                        cityId = nil
                        amount = 790
                        
                        let branches = operation.parameters.first(where: { $0.id == .branches })
                        switch branches {
                        case let .select(select):
                            officeId = select.value
                        default:
                            break
                        }
                        
                    } else {
                        
                        deliverToOffice = false
                        officeId = nil
                        amount = 1500
                        
                        let city = operation.parameters.first(where: { $0.id == .city })
                        switch city {
                        case let .select(select):
                            cityId = Int(select.value ?? "")
                        default:
                            break
                        }
                    }
                    
                default: break
                }
                
                let stickerPayment = StickerPayment(
                    currencyAmount: "RUB",
                    amount: amount,
                    check: false,
                    payer: .init(cardId: cardId ?? ""),
                    productToOrderInfo: .init(
                        type: "STICKER",
                        deliverToOffice: deliverToOffice ?? false,
                        officeId: officeId,
                        cityId: cityId
                    ))
                
                processTransferService(stickerPayment) { result in
                        
                        switch result {
                        case let .success(success):
                            
                            var newOperation = operation
                            newOperation = newOperation.updateOperation(
                                operation: newOperation,
                                newParameter: .input(.init(
                                    value: "",
                                    title: "Введите код из смс",
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
                
                return .success(.operation(.init(state: .process, parameters: operation.parameters)))
            }
            
        case let .product(productEvents):
            return reduceProductEvent(productEvents, operation)
        }
    }
    
    fileprivate func reduceProductEvent(
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
    
    fileprivate func selectOption(
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
                        state: .idle(.init(iconName: "", title: citySelector.title)))
                    )
                    
                case let .banner(banner):
                    return Operation.Parameter.sticker(.init(
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
                    return Operation.Parameter.select(.init(
                        id: .officeSelector,
                        value: "",
                        title: officeSelector.title,
                        placeholder: officeSelector.subtitle,
                        options: [],
                        state: .idle(.init(iconName: "", title: officeSelector.title)))
                    )
                    
                case .product:
                    if let product = self.products.first {
                        
                        return Operation.Parameter.productSelector(.init(
                            state: .select,
                            selectedProduct: product,
                            allProducts: self.products
                        ))
                    } else {
                        
                        return nil
                    }
                
                case let .selector(selector):
                    return Operation.Parameter.select(.init(
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
                        state: .idle(.init(iconName: "", title: selector.title)))
                    )
                
                case let .hint(hint):
                    return Operation.Parameter.tip(.init(title: hint.title))
                  
                case .separator:
                    return nil

                case .separatorGroup:
                    return nil

                case .pageTitle:
                    return nil

                case .noValid:
                    return nil
                }
            }.compactMap{ $0 }
            
            return .operation(.init(parameters: parameters))

        case let .deliveryCourier(deliveryCourier):

            return .operation(.init(parameters: []))

        case let .deliveryOffice(deliveryOffice):
            
            let parameters = deliveryOffice.main.map { main in
                
                switch main.data {
                case let .citySelector(citySelector):
                    return Operation.Parameter.select(.init(
                        id: .citySelector,
                        value: nil,
                        title: citySelector.title,
                        placeholder: citySelector.subtitle,
                        options: self.cityList.map({ Operation.Parameter.Select.Option(
                            id: $0.id,
                            name: $0.name,
                            iconName: ""
                        )}),
                        state: .idle(.init(iconName: "", title: citySelector.title)))
                    )
                    
              case let .officeSelector(officeSelector):
                    return Operation.Parameter.select(.init(
                        id: .officeSelector,
                        value: nil,
                        title: officeSelector.title,
                        placeholder: officeSelector.subtitle,
                        options: [],
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
            case let .success(images):
                    
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
}

// MARK: Helpers

extension PaymentSticker.ParameterViewModel {
    
    var inputTitle: String? {
        
        guard case let .input(title, _) = self else {
            return nil
        }
        
        return title
    }
}

extension PaymentSticker.Operation.Parameter {

    var inputTitle: String? {
        
        guard case let .input(input) = self else {
            return nil
        }
        
        return input.title
    }
}

extension Array where Element == PaymentSticker.Operation.Parameter {
    
    var inputTitle: String? {
        
        first(where: { $0.id == .input })?.inputTitle
    }
}

