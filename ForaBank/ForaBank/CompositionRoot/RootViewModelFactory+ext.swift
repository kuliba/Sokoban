//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Foundation
import SberQR
import PaymentSticker
import SwiftUI

extension RootViewModelFactory {
    
    typealias MakeOperationStateViewModel = (@escaping BusinessLogic.SelectOffice) -> OperationStateViewModel
    
    static func make(
        httpClient: HTTPClient,
        model: Model,
        logger: LoggerAgentProtocol,
        qrResolverFeatureFlag: QRResolverFeatureFlag
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
        
        let infoNetworkLog = { logger.log(level: .info, category: .network, message: $0, file: $1, line: $2) }
        
        let sberQRServices = Services.makeSberQRServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let qrViewModelFactory = makeQRViewModelFactory(
            model: model,
            logger: logger,
            qrResolverFeatureFlag: qrResolverFeatureFlag
        )
        
        let makeProductProfileViewModel = ProductProfileViewModel.make(
            with: model,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            cvvPINServicesClient: cvvPINServicesClient
        )
        
        return make(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            onRegister: resetCVVPINActivation
        )
    }
    
    static func makeNavigationOperationView(
        httpClient: HTTPClient,
        model: Model,
        dismissAll: @escaping() -> Void
    ) -> () -> some View {
     
        return makeNavigationOperationView
        
        func operationView(
            setSelection: (@escaping (Location, @escaping NavigationFeatureViewModel.Completion) -> Void)
        ) -> some View {
         
            let makeOperationStateViewModel = makeOperationStateViewModel(
                httpClient,
                model: model
            )
            
            return OperationView(
                model: makeOperationStateViewModel(setSelection),
                operationResultView: { result in
                    
                    OperationResultView(
                        model: result,
                        buttonsView: makeStickerDetailDocumentButtons(
                            httpClient: httpClient,
                            model: model
                        ),
                        mainButtonAction: dismissAll,
                        configuration: .default
                    )
                },
                configuration: .default
            )
        }
        
        func dictionaryAtmList(location: Location) -> [AtmData] {
            
            model.dictionaryAtmList()?
                .filter({ $0.cityId.description == location.id })
                .filter({ $0.serviceIdList.contains(where: { $0 == 140 } )}) ?? []
        }
        
        func dictionaryAtmMetroStations() -> [AtmMetroStationData] {
            
            model.dictionaryAtmMetroStations() ?? []
        }
        
        func listView(
            location: Location,
            completion: @escaping (Office?) -> Void
        ) -> some View {
            
            PlacesListInternalView(
                items: dictionaryAtmList(location: location).map { item in
                    PlacesListViewModel.ItemViewModel(
                        id: item.id,
                        name: item.name,
                        address: item.address,
                        metro: dictionaryAtmMetroStations().filter({
                            item.metroStationList.contains($0.id)
                        }).map({
                            PlacesListViewModel.ItemViewModel.MetroStationViewModel(
                                id: $0.id,
                                name: $0.name,
                                color: $0.color.color
                            )
                        }),
                        schedule: item.schedule,
                        distance: nil
                    )
                },
                selectItem: { item in
                    
                    completion(Office(id: item.id, name: item.name))
                }
            )
            
        }
        
        //NavigationOperationView
        func makeNavigationOperationView() -> some View {
            
            NavigationOperationView(
                location: .init(id: ""),
                viewModel: .init(),
                operationView: operationView,
                listView: listView
            )
        }
    }
    
    static func makeStickerDetailDocumentButtons(
        httpClient: HTTPClient,
        model: Model
    ) -> (
        PaymentSticker.OperationResult.PaymentID
    ) -> some View {
        
        let makeDetailButton = makeOperationDetailButton(
            httpClient: httpClient,
            model: model
        )
        
        let makeDocumentButton = makeDocumentButton(
            httpClient: httpClient,
            model: model
        )
        
        return make
        
        func make(
            paymentID: PaymentSticker.OperationResult.PaymentID
        ) -> some View {
            
            HStack {
                
                makeDetailButton(.init("\(paymentID.id)"))
                makeDocumentButton(.init(paymentID.id))
            }
        }
    }
}

extension ProductProfileViewModel {
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?

    static func make(
        with model: Model,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        cvvPINServicesClient: CVVPINServicesClient
    ) -> MakeProductProfileViewModel {
        
        return { product, rootView, dismissAction in
                .init(
                    model,
                    sberQRServices: sberQRServices,
                    qrViewModelFactory: qrViewModelFactory,
                    cvvPINServicesClient: cvvPINServicesClient,
                    product: product,
                    rootView: rootView,
                    dismissAction: dismissAction
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
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        onRegister: @escaping OnRegister
    ) -> RootViewModel {
        
        let mainViewModel = MainViewModel(
            model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            onRegister: onRegister
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory
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
}
