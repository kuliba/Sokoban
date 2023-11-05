//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.11.2023.
//

import Foundation
import GenericRemoteService
import PaymentSticker

func unimplemented<T>(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> T {
    
    fatalError("Unimplemented: \(message)", file: file, line: line)
}

enum RootViewModelFactory {
    
    static func make(
        with model: Model
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        
        let mainViewModel = MainViewModel(
            model,
            sections: MainSectionViewModel.makeMainSection(model),
            makeOperationStateViewModel: {
                
                OperationStateViewModel(
                    businessLogic: .init(
                        dictionaryService: unimplemented(),//Services.stickerDictRequest(
//                            input: .stickerDeliveryOffice,
//                            httpClient: httpClient
//                        ),
                        transfer: { event, completion in
                           
                        }
                    )
                )
            }
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
}
