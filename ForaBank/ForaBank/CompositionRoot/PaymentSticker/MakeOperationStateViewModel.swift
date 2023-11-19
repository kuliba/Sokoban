//
//  MakeOperationStateViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation
import PaymentSticker
import GenericRemoteService

extension RootViewModelFactory {
    
    static func makeOperationStateViewModel(
        _ httpClient: HTTPClient,
        model: Model
    ) -> MakeOperationStateViewModel {
        
        return {
            
            let dictionaryService = Services.makeGetStickerDictService(
                httpClient: httpClient
            )
            let transferService = Services.makeCommissionProductTransferService(
                httpClient: httpClient
            )
            let makeTransferService = Services.makeTransferService(
                httpClient: httpClient
            )
            let makeImageLoaderService = Services.makeImageListService(
                httpClient: httpClient
            )
            let processImageLoader = Services.makeImageListService(
                httpClient: httpClient
            )
            
            let businessLogic = BusinessLogic(
                processDictionaryService: dictionaryService.process,
                processTransferService: {_,_ in fatalError()},
                processMakeTransferService: {_,_ in fatalError()},
                processImageLoaderService: {_,_ in fatalError()},
                selectOffice: $0,
                products: model.productsMapper(model: model),
                cityList: model.citiesMapper(model: model)
            )
            
            return OperationStateViewModel(blackBoxGet: businessLogic.operationResult)
        }
    }
}

private extension BusinessLogic {
    
    func operationResult(
        request: (
            operation: PaymentSticker.Operation,
            event: Event
        ),
        completion: @escaping (OperationResult) -> Void
    ) {
        
        operationResult(operation: request.operation, event: request.event, completion: completion)
    }
}

private extension RemoteService
where Input == RequestFactory.GetJsonAbroadType,
      Output == StickerDictionaryResponse,
      CreateRequestError == Error,
      PerformRequestError == Error,
      MapResponseError == ResponseMapper.StickerDictionaryError {
    
    typealias DictionaryServiceCompletion = (Result<StickerDictionary, StickerDictionaryError>) -> Void
    func process(
        input: GetJsonAbroadType,
        completion: @escaping DictionaryServiceCompletion
    ) {
        process(
            .init(input)
        ) { result in

            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
            case let .success(success):
                completion(.success(.init(success)))
            }
        }
    }
}

private extension RequestFactory.GetJsonAbroadType {
    
    init(_ input: GetJsonAbroadType) {
        
        switch input {
        case .stickerOrderDeliveryCourier:
            self = .stickerOrderDeliveryCourier
        case .stickerOrderDeliveryOffice:
            self = .stickerOrderDeliveryOffice
        case .stickerOrderForm:
            self = .stickerOrderForm
        }
    }
}

private extension StickerDictionary {
    
    init(_ success: StickerDictionaryResponse) {
        fatalError()
//        switch success {
//        case let .orderForm(stickerOrderForm):
//            return .orderForm(.init(
//                header: <#[StickerDictionary.StickerOrderForm.Header]#>,
//                main: <#[StickerDictionary.Main]#>,
//                serial: <#String#>
//            ))
//
//        case let .deliveryOffice(deliveryOffice):
//            completion(.success(.deliveryOffice(.init)))
//
//        case let .deliveryCourier(deliveryCourier):
//            completion(.success(deliveryCourier))
//        }
    }
}

private extension StickerDictionaryError {
    
    init(_ error: MappingRemoteServiceError<ResponseMapper.StickerDictionaryError>) {
        fatalError()
    }
}

private extension Model {
    
    func productsMapper(
        model: Model
    ) -> [BusinessLogic.Product] {
        
        let allProducts = model.allProducts.map({ BusinessLogic.Product(
            title: "Счет списания",
            nameProduct: $0.displayName,
            balance: $0.balanceValue.description,
            description: $0.displayNumber ?? "",
            cardImage: PaymentSticker.ImageData.data($0.smallDesign.uiImage?.pngData()),
            paymentSystem: PaymentSticker.ImageData.data($0.paymentSystemData),
            backgroundImage: PaymentSticker.ImageData.data($0.largeDesign.uiImage?.pngData()),
            backgroundColor: $0.backgroundColor.description
        )})
        
        return allProducts
    }
    
    func citiesMapper(
        model: Model
    ) -> [BusinessLogic.City] {
        
        let cities = model.localAgent.load(type: [AtmCityData].self)
        return (cities?.compactMap{ $0 }.map({ BusinessLogic.City(id: $0.id.description, name: $0.name) })) ?? []
    }
}
