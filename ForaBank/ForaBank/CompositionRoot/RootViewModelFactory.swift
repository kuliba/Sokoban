//
//  RootViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import Foundation

enum RootViewModelFactory {
    
    static func make(
        with model: Model
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        let cvvPinService = Services.cvvPinService(
            httpClient: httpClient
        )
        let mainViewModel = MainViewModel(
            model,
            certificateClient: cvvPinService
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            certificateClient: cvvPinService
        )
        
        let chatViewModel = ChatViewModel()
        
        let informerViewModel = InformerView.ViewModel(
            model
        )
        
        return .init(
            mainViewModel: mainViewModel,
            paymentsViewModel: paymentsViewModel,
            chatViewModel: chatViewModel,
            informerViewModel: informerViewModel,
            model
        )
    }
}
