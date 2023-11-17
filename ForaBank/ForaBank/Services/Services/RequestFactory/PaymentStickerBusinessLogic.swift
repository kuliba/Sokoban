//
//  BusinessLogic.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 23.10.2023.
//

import Foundation
import Combine
import GenericRemoteService
import PaymentSticker
import SVGKit

struct Location {
    
    let id: String
}

struct Office {
    
    let id: String
    let name: String
}

final class BusinessLogic {
    
    typealias DictionaryService = RemoteServiceOf<RequestFactory.GetJsonAbroadType, StickerDictionaryResponse>
    typealias TransferService = RemoteServiceOf<RequestFactory.StickerPayment, CommissionProductTransferResponse>
    typealias MakeTransferService = RemoteServiceOf<String, MakeTransferResponse>
    typealias ImageLoaderService = RemoteServiceOf<[String], [ImageData]>
    
    typealias Product = PaymentSticker.Operation.Parameter.ProductSelector.Product
    typealias OperationResult = Result<OperationStateViewModel.State, Error>
    
    typealias SelectOffice = (Location, _ completion: @escaping (Office?) -> Void) -> Void
    
    //TODO: replace remoteService to closure or protocol
    let dictionaryService: DictionaryService
    let transferService: TransferService
    let makeTransferService: MakeTransferService
    let imageLoaderService: ImageLoaderService
    let selectOffice: SelectOffice
    let products: [Product]
    let cityList: [City]
    
    init(
        dictionaryService: DictionaryService,
        transferService: TransferService,
        makeTransferService: MakeTransferService,
        imageLoaderService: ImageLoaderService,
        selectOffice: @escaping SelectOffice,
        products: [Product],
        cityList: [City]
    ) {
        self.dictionaryService = dictionaryService
        self.transferService = transferService
        self.makeTransferService = makeTransferService
        self.imageLoaderService = imageLoaderService
        self.selectOffice = selectOffice
        self.products = products
        self.cityList = cityList
    }
}

extension OperationStateViewModel {
    
    convenience init(
        businessLogic: BusinessLogic
    ) {
        self.init(blackBoxGet: { request, completion in
            
            let (operation, event) = request
            businessLogic.operationResult(
                operation: operation,
                event: event,
                completion: completion
            )
        })
    }
}

extension BusinessLogic {
    
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
                    id: id,
                    operation: operation,
                    parameter: parameter
                )
                 
                if parameter.id == .officeSelector {
                
                    let newOperation = operation.updateOperation(operation: operation, newParameter: .select(parameter))
                    completion(.success(.operation(newOperation)))
                    return .success(.operation(newOperation))

                }
                
                switch parameter.id {
                case .transferTypeSticker:
                    
                    if id == "typeDeliveryOffice" {
                     
                        dictionaryService.process(.stickerOrderDeliveryOffice) { result in
                            
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
                        
                    } else {
                        
                        dictionaryService.process(.stickerOrderDeliveryCourier) { result in
                            
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
                            newParameter: .select(.init(id: .officeSelector, value: office.id, title: "", placeholder: "", options: [], state: .selected(.init(title: "", placeholder: "", name: office.name, iconName: "")))))
                        
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
                    
                    let parameter = select.updateState(
                        iconName: selectedViewModel.iconName
                    )
                    
                    return .success(.operation(operation.updateOperation(
                        operation: operation,
                        newParameter: .select(parameter)
                    )))
                    
                case let .list(listViewModel):
                    
                    let parameter = select.updateState(
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
                
                let parametersUpdate = operation.updateOperation(
                    operation: operation,
                    newParameter: .input(input)
                )
                return .success(.operation(parametersUpdate))
            }
            
        case .continueButtonTapped:
           
            if operation.parameters.count == 0 {
                
                dictionaryService.process(.stickerOrderForm) { result in
                    
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
                
                return .success(.operation(operation))
                
            } else if let input = operation.parameters.first(where: { $0.id == .input }) {
                
                switch input {
                case let .input(input):
                    
                    makeTransferService.process(input.value) { result in
                       
                        switch result {
                        case let .success(makeTransfer):
                            completion(.success(.result(OperationStateViewModel.OperationResult(
                                result: .success,
                                title: "Успешная заявка",
                                description: makeTransfer.data.productOrderingResponseMessage,
                                amount: "100"
                            ))))

                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                    return .success(.operation(operation))

                default:
                    return .success(.operation(operation))
                }
                
            } else {
             
                transferService.process(.init(
                    currencyAmount: "RUB",
                    amount: 790,
                    check: false,
                    payer: .init(cardId: "10000114306"),
                    productToOrderInfo: .init(
                        type: "STICKER",
                        deliverToOffice: true,
                        officeId: "1112"
                    ))) { result in
                        
                        switch result {
                        case .success:
                            
                            var newOperation = operation
                            newOperation = newOperation.updateOperation(
                                operation: newOperation,
                                newParameter: .input(.init(
                                    value: "",
                                    title: "Введите код из смс"
                                ))
                            )
                            
                            newOperation = newOperation.updateOperation(
                                operation: newOperation,
                                newParameter: .amount(.init(value: "790 ₽"))
                            )
                            
                            completion(.success(.operation(newOperation)))

                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                
                return .success(.operation(operation))
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
            
            let operation = operation.updateOperation(
                operation: operation,
                newParameter: .productSelector(.init(
                    state: .select,
                    selectedProduct: option,
                    allProducts: product.allProducts))
            )
            
            return .success(.operation(operation))
        }
    }
    
    fileprivate func selectOption(
        id: String,
        operation: PaymentSticker.Operation,
        parameter: PaymentSticker.Operation.Parameter.Select
    ) -> PaymentSticker.Operation {
        
        guard let option = parameter.options.first(where: { $0.id == id })
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
        _ dictionaryResponse: StickerDictionaryResponse
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
                        value: "",
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
                        value: "",
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
                      value: "",
                      title: officeSelector.title,
                      placeholder: officeSelector.subtitle,
                      options: [],
                      state: .idle(.init(iconName: "", title: officeSelector.title)))
                  )
                    
                default:
                    return nil
                }
            }.compactMap{ $0 }
            
            var newOperation: [PaymentSticker.Operation.Parameter] = operation.parameters
            
            for parameter in parameters {
                
                if !operation.parameters.contains(where: { $0.id == parameter.id }) {
                    
                    newOperation.append(parameter)
                }
            }
            
            return .operation(.init(parameters: newOperation))
        }
    }
    
    func imageLoader(
        operation: PaymentSticker.Operation,
        banner: StickerDictionaryResponse.Banner,
        completion: @escaping (OperationResult) -> Void
    ) {
        
        self.imageLoaderService.process([banner.md5hash]) { result in
            
            switch result {
            case let .success(images):
                    
                let newOperation = operation.updateOperation(
                    operation: operation,
                    newParameter: .sticker(.init(
                        title: banner.title,
                        description: banner.subtitle,
                        image: .data(images.first?.data),
                        options: banner.txtConditionList.map { item in
                            
                                .init(
                                    title: item.name,
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
    
    struct City {
        
        let id: String
        let name: String
    }
}
