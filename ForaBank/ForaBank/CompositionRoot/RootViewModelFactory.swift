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
        #warning("replace `cvvPinService` with `certificateClient`")
        let certificateClient = Services.cvvPinService(
            httpClient: httpClient
        )
        let mainViewModel = MainViewModel(
            model,
            certificateClient: certificateClient
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            certificateClient: certificateClient
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
