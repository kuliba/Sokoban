//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Foundation
import PaymentSticker
import SwiftUI

extension RootViewModelFactory {
    
    typealias MakeOperationStateViewModel = (@escaping BusinessLogic.SelectOffice) -> OperationStateViewModel
    
    static func make(
        httpClient: HTTPClient,
        model: Model,
        logger: LoggerAgentProtocol
    ) -> RootViewModel {
        
        let rsaKeyPairStore = makeLoggingStore(
            store: KeyTagKeyChainStore<RSADomain.KeyPair>(
                keyTag: .rsa
            ),
            logger: logger
        )
        
        let resetCVVPINActivation = makeResetCVVPINActivation(
            rsaKeyPairStore: rsaKeyPairStore,
            logger: logger
        )
        
        let cvvPINServicesClient = Services.cvvPINServicesClient(
            httpClient: httpClient,
            logger: logger,
            rsaKeyPairStore: rsaKeyPairStore
        )
        
        let makeProductProfileViewModel = {
            
            ProductProfileViewModel(
                model,
                cvvPINServicesClient: cvvPINServicesClient,
                product: $0,
                rootView: $1,
                dismissAction: $2
            )
        }
        
        return make(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            onRegister: resetCVVPINActivation
        )
    }
    
    static func makeNavigationOperationView(
        httpClient: HTTPClient,
        model: Model
    ) -> () -> some View {
     
        return makeNavigationOperationView
        
        func makeButtons(
            paymentID: PaymentSticker.PaymentID,
            documentID: PaymentSticker.DocumentID
        ) -> some View {
            
            let makeDetailButton = makeOperationDetailButton(
                httpClient: httpClient,
                model: model
            )
            
            let makeDocumentButton = makeDocumentButton(
                httpClient: httpClient,
                model: model
            )
            
            return HStack {
                
                makeDetailButton(.init(paymentID.id))
                makeDocumentButton(.init(documentID.id))
            }
        }
        
        func operationView(setSelection: (@escaping (Location, @escaping NavigationFeatureViewModel.Completion) -> Void)) -> some View {
         
            let makeOperationStateViewModel = makeOperationStateViewModel(
                httpClient,
                model: model
            )
            
            return OperationView(
                model: makeOperationStateViewModel(setSelection),
                operationResultView: { result in
                    
                    OperationResultView(
                        model: result,
                        buttonsView: makeButtons(paymentID:documentID:))
                },
                configuration: .default
            )
        }
        
        func dictionaryAtmList() -> [AtmData] {
            
            model.dictionaryAtmList() ?? []
        }
        
        func dictionaryAtmMetroStations() -> [AtmMetroStationData] {
            
            model.dictionaryAtmMetroStations() ?? []
        }
        
        func listView(
            location: Location,
            completion: @escaping (Office?) -> Void
        ) -> some View {
            
            PlacesListInternalView(
                items: dictionaryAtmList().map { PlacesListViewModel.ItemViewModel(
                    id: $0.id,
                    name: $0.name,
                    address: $0.address,
                    metro: dictionaryAtmMetroStations().compactMap {
                        
                        PlacesListViewModel.ItemViewModel.MetroStationViewModel(
                            id: $0.id, name: $0.name, color: $0.color.color
                        )
                        
                    },
                    schedule: $0.schedule,
                    distance: nil
                ) },
                selectItem: { item in
                    
                    completion(Office(id: item.id, name: item.name))
                }
            )
            
        }
        
        //NavigationOperationView
        func makeNavigationOperationView() -> some View {
            
            NavigationOperationView(
                viewModel: .init(),
                operationView: operationView,
                listView: listView
            )
        }
    }
}

// TODO: needs better naming
private extension RootViewModelFactory {
    
    static func makeLoggingStore<Key>(
        store: any Store<Key>,
        logger: LoggerAgentProtocol
    ) -> any Store<Key> {
        
        let log = { logger.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        
        return LoggingStoreDecorator(
            decoratee: store,
            log: log
        )
    }
    
    typealias ResetCVVPINActivation = () -> Void
    
    static func makeResetCVVPINActivation(
        rsaKeyPairStore: any Store<RSADomain.KeyPair>,
        logger: LoggerAgentProtocol
    ) -> ResetCVVPINActivation {
        
        return rsaKeyPairStore.deleteCacheIgnoringResult
    }
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnRegister = () -> Void
    
    static func make(
        model: Model,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        onRegister: @escaping OnRegister
    ) -> RootViewModel {
        
        let mainViewModel = MainViewModel(
            model,
            sections: makeMainSections(model: model),
            makeProductProfileViewModel: makeProductProfileViewModel,
            onRegister: onRegister
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel
        )
        
        let chatViewModel = ChatViewModel()
        
        let informerViewModel = InformerView.ViewModel(model)
        
        let showLoginAction = {
            
            let loginViewModel = ComposedLoginViewModel(
                authLoginViewModel: .init(
                    model,
                    rootActions: $0,
                    onRegister: onRegister
                )
            )
            
            return RootViewModelAction.Cover.ShowLogin(viewModel: loginViewModel)
        }
        
        return .init(
            mainViewModel: mainViewModel,
            paymentsViewModel: paymentsViewModel,
            chatViewModel: chatViewModel,
            informerViewModel: informerViewModel,
            model,
            showLoginAction: showLoginAction
        )
    }
    
    static func makeMainSections(
        model: Model
    ) -> [MainSectionViewModel] {
        
        return [
            MainSectionProductsView.ViewModel(model),
            MainSectionFastOperationView.ViewModel(),
            MainSectionPromoView.ViewModel(model),
            MainSectionCurrencyMetallView.ViewModel(model),
            MainSectionOpenProductView.ViewModel(model),
            MainSectionAtmView.ViewModel.initial
        ]
    }
}
