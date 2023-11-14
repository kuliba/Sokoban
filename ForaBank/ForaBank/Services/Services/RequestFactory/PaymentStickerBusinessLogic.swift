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

final class BusinessLogic {
    
    typealias Product = PaymentSticker.Operation.Parameter.Product.Option
    typealias Option = PaymentSticker.Operation.Parameter.Select.Option
    typealias OperationResult = Result<OperationStateViewModel.State, Error>
    typealias Completion = (OperationResult) -> Void
    typealias Load = (PaymentSticker.Operation, Event, @escaping Completion) -> AnyPublisher<OperationResult, Never>
    
    typealias TransferResult = Result<TransferResponse, TransferError>
    typealias TransferCompletion = (TransferResult) -> Void
    typealias Transfer = (TransferEvent, @escaping TransferCompletion) -> Void
    
    //TODO: replace remoteService to closure or protocol
    let dictionaryService: RemoteService<RequestFactory.GetJsonAbroadType, StickerDictionaryResponse>
    let transferService: RemoteService<RequestFactory.StickerPayment, CommissionProductTransferResponse>
    let makeTransferService: RemoteService<String, MakeTransferResponse>
    let imageLoaderService: RemoteService<[String], [ImageData]>
    let transfer: Transfer
    let products: [Product]
    let cityList: [City]
    
    init(
        dictionaryService: RemoteService<RequestFactory.GetJsonAbroadType, StickerDictionaryResponse>,
        transferService: RemoteService<RequestFactory.StickerPayment, CommissionProductTransferResponse>,
        makeTransferService: RemoteService<String, MakeTransferResponse>,
        imageLoaderService: RemoteService<[String], [ImageData]>,
        transfer: @escaping Transfer,
        products: [Product],
        cityList: [City]
    ) {
        self.dictionaryService = dictionaryService
        self.transferService = transferService
        self.makeTransferService = makeTransferService
        self.imageLoaderService = imageLoaderService
        self.transfer = transfer
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
                 
                if id == "typeDeliveryOffice" {
                 
                    dictionaryService.process(.stickerOrderDeliveryOffice) { result in
                        
                        switch result {
                        case let .success(dictionaryResponse):
                            completion(.success(self.dictionaryStickerReduce(
                                operation,
                                dictionaryResponse
                            )))
                            
                        case let .failure(error):
                           return
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
                           return
                        }
                    }
                }
                
                return .success(.operation(operation))
            
            case .openBranch:
                return .success(.branches)
                
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
                                            return
                                        }
                                    }
                                    
                                default: break
                                }
                            default:
                                break
                            }
                        case .result(let operationResult):
                            return
                        case .branches:
                            return
                        }
                    case let .failure(error):
                        return
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
                            return
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
                            
                            completion(.success(.operation(operation.updateOperation(
                                operation: operation,
                                newParameter: .input(.init(
                                    value: "",
                                    title: "Введите код из смс"
                                ))
                            ))))

                        case let .failure(error):
                            return
                        }
                    }
                
                return .success(.operation(operation))
            }
            
        case let .product(productEvents):
            return reduceProductEvent(productEvents, operation)
            
        default:
            return .success(.operation(operation))
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
                newParameter: .product(.init(
                    state: state,
                    selectedProduct: product.selectedProduct,
                    allProducts: product.allProducts
                ))
            )
            return .success(.operation(newOperation))
            
        case let .selectProduct(option, product):
            
            let operation = operation.updateOperation(
                operation: operation,
                newParameter: .product(.init(
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
                        image: PaymentSticker.ImageData(data: Data()),
                        options: banner.txtConditionList.map({
                            
                            Operation.Parameter.Sticker.Option(
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
                        
                        return Operation.Parameter.product(.init(
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
                if let uiImage = SVGKImage(data: images.first?.data).uiImage,
                   let image = PaymentSticker.ImageData(with: uiImage) {
                    
                    let newOperation = operation.updateOperation(
                        operation: operation,
                        newParameter: .sticker(.init(
                            title: banner.title,
                            description: banner.subtitle,
                            image: image,
                            options: banner.txtConditionList.map { item in
                                
                                    .init(
                                        title: item.name,
                                        description: "\(item.value.description.dropLast(2)) ₽"
                                    )
                            }
                        ))
                    )
                    
                    completion(.success(.operation(newOperation)))
                }
                
            case let .failure(error):
                return
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
    
    typealias TransferPayload = TransferEvent
    
    public enum TransferResponse {
        
        case deliveryOffice(DeliveryOffice)
    }
    
    public struct DeliveryOffice {
        
        let main: [Main]
        
        public struct Main {
            
            let type: TypeSelector
            let data: Data
            
            public enum TypeSelector: String {
            
                case separatorStartOperation = "SeparatorStartOperation"
                case citySelector = "CitySelector"
                case separatorEndOperation = "SeparatorEndOperation"
            }
            
            public struct Data {
                
                let title: String
                let subtitle: String
                let isCityList: Bool
                let md5hash: String
                let color: String
            }
        }
    }
    
    public enum TransferError: Error {}
    
    public enum TransferEvent {
    
        case operation(PaymentSticker.Operation)
        case requestOTP
    }
    
    public enum State {
        
        case local(OperationResult)
        case remote(OperationResult)
    }
}
