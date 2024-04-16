//
//  MakeOperationStateViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation
import PaymentSticker
import GenericRemoteService
import SwiftUI

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
            let imageLoaderService = Services.makeImageListService(
                httpClient: httpClient
            )
            
            let businessLogic = BusinessLogic(
                processDictionaryService: dictionaryService.dictionaryProcess,
                processTransferService: transferService.transferProcess,
                processMakeTransferService: makeTransferService.makeTransferProcess,
                processImageLoaderService: imageLoaderService.imageProcess,
                selectOffice: $0,
                products: { model.productsMapper() },
                cityList: { model.citiesMapper($0) }
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
        process(
            operation: request.operation,
            event: request.event,
            completion: completion
        )
    }
}

private extension RemoteService
where Input == [String],
      Output == [ImageData],
      CreateRequestError == Error,
      PerformRequestError == Error,
      MapResponseError == GetImageListError {
    
    typealias ImagesResult = Result<[PaymentSticker.ImageData], GetImageListError>
    typealias ImageServiceCompletion = (ImagesResult) -> Void
    
    func imageProcess(
        input: [String],
        completion: @escaping ImageServiceCompletion
    ) {
        process(
            input
        ) { result in

            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
                
            case let .success(success):
                completion(.success(success.map{
                    
                    PaymentSticker.ImageData.data($0.data)
                }))
            }
        }
    }
}

private extension GetImageListError {
    
    init(_ error: MappingRemoteServiceError<GetImageListError>) {
        
        self = .error(statusCode: error._code, errorMessage: error.localizedDescription)
    }
}

private extension RemoteService
where Input == String,
      Output == MakeTransfer,
      CreateRequestError == Error,
      PerformRequestError == Error,
      MapResponseError == MakeTransferError {
    
    typealias MakeTransferResult = Result<MakeTransferResponse, MakeTransferError>
    typealias MakeTransferServiceCompletion = (MakeTransferResult) -> Void
    
    func makeTransferProcess(
        input: String,
        completion: @escaping MakeTransferServiceCompletion
    ) {
        process(
            input
        ) { result in

            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
                
            case let .success(success):
                completion(.success(.init(
                    paymentOperationDetailId: success.paymentOperationDetailId,
                    documentStatus: success.documentStatus,
                    productOrderingResponseMessage: success.productOrderingResponseMessage
                )))
            }
        }
    }
}

private extension MakeTransferError {
    
    init(_ error: MappingRemoteServiceError<MakeTransferError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension RemoteService
where Input == RequestFactory.StickerPayment,
      Output == CommissionProductTransfer,
      CreateRequestError == Error,
      PerformRequestError == Error,
      MapResponseError == CommissionProductTransferError {
    
    typealias TransferResult = Result<CommissionProductTransfer, CommissionProductTransferError>
    typealias TransferServiceCompletion = (TransferResult) -> Void
    
    func transferProcess(
        input: StickerPayment,
        completion: @escaping TransferServiceCompletion
    ) {
        process(
            .init(
                currencyAmount: input.currencyAmount,
                amount: input.amount,
                check: input.check,
                payer: .init(cardId: input.payer.cardId),
                productToOrderInfo: .init(
                    type: input.productToOrderInfo.type,
                    deliverToOffice: input.productToOrderInfo.deliverToOffice,
                    officeId: input.productToOrderInfo.officeId ?? nil,
                    cityId: input.productToOrderInfo.cityId ?? nil
                ))
        ) { result in

            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
                
            case let .success(success):
                completion(.success(success))
            }
        }
    }
}

private extension CommissionProductTransferError {
    
    init(_ error: MappingRemoteServiceError<CommissionProductTransferError>) {
        
        self = .error(statusCode: error._code, errorMessage: error.localizedDescription)
    }
}

private extension RemoteService
where Input == RequestFactory.GetJsonAbroadType,
      Output == StickerDictionaryResponse,
      CreateRequestError == Error,
      PerformRequestError == Error,
      MapResponseError == ResponseMapper.StickerDictionaryError {
    
    typealias DictionaryResult = Result<StickerDictionary, StickerDictionaryError>
    typealias DictionaryServiceCompletion = (DictionaryResult) -> Void
    
    func dictionaryProcess(
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
        
        switch success {
        case let .orderForm(stickerOrderForm):
            let header = stickerOrderForm.header.map {
                StickerOrderForm.Header(
                    type: .init(rawValue: $0.type.rawValue) ?? .pageTitle,
                    data: .init(
                        title: $0.data.title,
                        isFixed: $0.data.isFixed
                    ))
            }
            
            let main = componentMapper(stickerOrderForm.main)
            
            self = .orderForm(.init(
                header: header,
                main: main,
                serial: stickerOrderForm.serial
            ))
            
        case let .deliveryType(deliveryType):
            let main = componentMapper(deliveryType.main)
            self = .deliveryType(.init(main: main, serial: deliveryType.serial))
        }
    }
}

private func componentMapper(
    _ main: [StickerDictionaryResponse.Main]
) -> [StickerDictionary.Main] {
    
    return main.map {
        switch $0.data {
        case let .banner(banner):
            return StickerDictionary.Main(
                type: .init(rawValue: $0.type.rawValue) ?? .pageTitle,
                data: .banner(.init(
                    title: banner.title,
                    subtitle: banner.subtitle,
                    currencyCode: banner.currencyCode,
                    currency: banner.currency,
                    md5hash: banner.md5hash,
                    txtConditionList: banner.txtConditionList.map {
                        StickerDictionary.Banner.Condition(
                            name: $0.name,
                            description: $0.description,
                            value: $0.value
                        )
                    })
                )
            )
        case let .hint(hint):
            return .init(
                type: .textsWithIconHorizontal,
                data: .hint(.init(
                    title: hint.title,
                    md5hash: hint.md5hash,
                    contentCenterAndPull: hint.contentCenterAndPull
                )))
        case let .product(product):
            return .init(
                type: .productSelect,
                data: .product(.init(
                    withoutPadding: product.withoutPadding
                ))
            )
        case let .separator(separator):
            return .init(
                type: .separator,
                data: .separator(.init(
                    color: separator.color
                ))
            )
        case .separatorGroup:
            return .init(
                type: .separatorSubGroup,
                data: .separatorGroup
            )
        case let .selector(selector):
            return .init(
                type: .selector,
                data: .selector(.init(
                    title: selector.title,
                    subtitle: selector.subtitle,
                    md5hash: selector.md5hash,
                    list: selector.list.map {
                        StickerDictionary.Selector.Option(
                            type: .init(rawValue: $0.type.rawValue) ?? .typeDeliveryCourier,
                            md5hash: $0.md5hash,
                            title: $0.title,
                            backgroundColor: $0.backgroundColor,
                            value: $0.value
                        )
                    })
                )
            )
            
        case let .citySelector(citySelector):
            return .init(
                type: .citySelector,
                data: .citySelector(.init(
                    title: citySelector.title,
                    subtitle: citySelector.subtitle,
                    isCityList: citySelector.isCityList,
                    md5hash: citySelector.md5hash
                ))
            )
            
        case let .officeSelector(officeSelector):
            return .init(
                type: .officeSelector,
                data: .officeSelector(.init(
                    title: officeSelector.title,
                    subtitle: officeSelector.subtitle,
                    md5hash: officeSelector.md5hash
                ))
            )
            
        case let .pageTitle(pageTitle):
            return .init(
                type: .pageTitle,
                data: .pageTitle(.init(
                    title: pageTitle.title,
                    isFixed: pageTitle.isFixed
                ))
            )
            
        case .noValid(_):
            return .init(type: .separator, data: .separatorGroup)
        }
    }
}

private extension StickerDictionaryError {
    
    init(_ error: MappingRemoteServiceError<ResponseMapper.StickerDictionaryError>) {
        
        self = .error(statusCode: error._code, errorMessage: error.localizedDescription)
    }
}

private extension Model {
    
    func productsMapper() -> [BusinessLogic.Product] {
        
        let cards = allProducts.compactMap { $0 as? ProductCardData }
        let products = cards.filter({ $0.isMain ?? false }).filter({ $0.allowDebit == true })
        
        let allProducts = products.map({ BusinessLogic.Product(
            id: $0.id,
            title: "Счет списания",
            nameProduct: $0.displayName,
            balance: $0.balanceValue,
            balanceFormatted: amountFormatted(
                amount: $0.balanceValue,
                currencyCode: $0.currency,
                style: .clipped
            ) ?? "",
            description: $0.displayNumber ?? "",
            cardImage: .data(self.images.value[$0.smallDesignMd5hash]?.uiImage?.pngData()),
            paymentSystem: .data(self.images.value[$0.paymentSystemImageMd5Hash]?.uiImage?.pngData()),
            backgroundImage: .data(self.images.value[$0.largeDesignMd5Hash]?.data),
            backgroundColor: $0.backgroundColor.description
        )})
        
        return allProducts
    }
    
    func citiesMapper(
        _ transferType: BusinessLogic.TransferType
    ) -> [BusinessLogic.City] {
        
        let cities = localAgent.load(type: [AtmCityData].self) ?? []
        
        switch transferType {
        case .courier:
            
            let filtered = cities
                .filter { ($0.productList ?? []).contains { $0 == .sticker }}
                .map { BusinessLogic.City(id: $0.id.description, name: $0.name) }
            
            return filtered
            
        case .office:
            let atmData = dictionaryAtmList()?
                .filter { $0.serviceIdList.contains { $0 == 140 }}
            
            let atmIDs = (atmData?.map(\.cityId) ?? []).uniqued()
            
            let filtered = cities
                .filter { city in atmIDs.contains { $0 == city.id }}
                .map { BusinessLogic.City(id: $0.id.description, name: $0.name) }
            
            return filtered
        }
    }
}
