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

final class BusinessLogic {
    
    typealias Option = PaymentSticker.Operation.Parameter.Select.Option
    typealias OperationResult = Result<OperationStateViewModel.State, Error>
    typealias Completion = (OperationResult) -> Void
    typealias Load = (PaymentSticker.Operation, Event, @escaping Completion) -> AnyPublisher<OperationResult, Never>
    
    typealias TransferResult = Result<TransferResponse, TransferError>
    typealias TransferCompletion = (TransferResult) -> Void
    typealias Transfer = (TransferEvent, @escaping TransferCompletion) -> Void
    
    let dictionaryService: RemoteService<RequestFactory.GetJsonAbroadType, StickerDictionaryResponse>
    let transfer: Transfer
    
    init(
        dictionaryService: RemoteService<RequestFactory.GetJsonAbroadType, StickerDictionaryResponse>,
        transfer: @escaping Transfer
    ) {
        self.dictionaryService = dictionaryService
        self.transfer = transfer
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
        
        let result: OperationResult = reduce(
            operation: operation,
            event: event,
            completion: completion
        )
        
        completion(result)
    }
}

extension BusinessLogic {
    
    //TODO: rename process
    func reduce(
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
            
                return .success(.operation(operation))
                
            case .openBranch:
                return .success(.operation(operation))
            }
            
        case .continueButtonTapped:
            
            transfer(.requestOTP) { result in
                
                switch result {
                case let .success(transferResponse):
                    
                    switch transferResponse {
                    case let .deliveryOffice(deliveryOffice):
                        
                        guard let deliveryOfficeParameter = deliveryOffice.main.first(where: { $0.type == .citySelector })
                        else { return }
                        
                        let newParameter: PaymentSticker.Operation.Parameter = .select(.init(
                            id: "deliveryOffice",
                            value: "",
                            title: deliveryOfficeParameter.data.title,
                            placeholder: deliveryOfficeParameter.data.subtitle,
                            options: [],
                            state: .idle(.init(iconName: "", title: deliveryOfficeParameter.data.title))
                        ))
                        let newOperation = operation.updateOperation(
                            operation: operation,
                            newParameter: newParameter
                        )
                        
                        completion(.success(.operation(newOperation)))
                    }
                    
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            
            return .success(.operation(operation))
            
        case let .product(productEvents):
            
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
        default:
            return .success(.operation(operation))
        }
    }
    
    func selectOption(
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
}

// MARK: - Types

extension BusinessLogic {
    
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
