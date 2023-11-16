//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.11.2023.
//

import Foundation
import GenericRemoteService
import PaymentSticker

enum RootViewModelFactory {
    
    static func make(
        with model: Model
    ) -> RootViewModel {
        let httpClient = model.authenticatedHTTPClient()
        
        let operationStateViewModelFactory = {
            
            OperationStateViewModel(businessLogic: .init(
                dictionaryService: Services.stickerDictRequest(
                    input: .stickerOrderForm,
                    httpClient: httpClient
                ),
                transferService: Services.createCommissionProductTransferRequest(
                    input: .init(parameters: []),
                    httpClient: httpClient
                ),
                makeTransferService: Services.makeTransferRequest(httpClient: httpClient),
                imageLoaderService: Services.getImageListRequest(httpClient: httpClient),
                changeNavigationState: $0,
                selectAtmOption: $1,
                products: model.productsMapper(model: model),
                cityList: model.citiesMapper(model: model)
            ))
        }
        
        let mainViewModel = MainViewModel(
            model,
            sections: MainSectionViewModel.makeMainSection(model),
            makeOperationStateViewModel: operationStateViewModelFactory
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(model: model)
        
        let chatViewModel = ChatViewModel()
        
        let informerViewModel = InformerView.ViewModel(model)
        
        return .init(
            mainViewModel: mainViewModel,
            paymentsViewModel: paymentsViewModel,
            chatViewModel: chatViewModel,
            informerViewModel: informerViewModel,
            model
        )
    }
}

extension Model {
    
    func authenticatedHTTPClient(
        httpClient: HTTPClient = HTTPFactory.loggingNoSharedCookieStoreURLSessionHTTPClient()
    ) -> HTTPClient {
        
        AuthenticatedHTTPClientDecorator(
            decoratee: httpClient,
            tokenProvider: self,
            signRequest: signRequest
        )
    }
    
    func productsMapper(
        model: Model
    ) -> [BusinessLogic.Product] {
        
        let allProducts = model.allProducts.map({ BusinessLogic.Product(
            title: "Счет списания",
            nameProduct: $0.displayName,
            balance: $0.balanceValue.description,
            description: $0.displayNumber ?? "",
            cardImage: PaymentSticker.ImageData(data: $0.smallDesign.uiImage?.pngData() ?? Data()),
            paymentSystem: PaymentSticker.ImageData(data: $0.paymentSystem.debugDescription.data),
            backgroundImage: PaymentSticker.ImageData(data: $0.largeDesign.uiImage?.pngData() ?? Data()),
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
