//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.11.2023.
//

import Foundation
import GenericRemoteService

enum RootViewModelFactory {
    
    static func make(
        with model: Model
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        
        let mainViewModel = MainViewModel(
            model,
            businessLogic: .init(
                dictionaryService: Services.stickerDictRequest(
                    input: .stickerDeliveryOffice,
                    httpClient: httpClient
                ),
                transfer: { event, completion in
                    
                }
            ))

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
}
