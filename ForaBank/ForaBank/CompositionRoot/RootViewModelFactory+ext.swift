//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Foundation

extension RootViewModelFactory {
    
    static func make(
        model: Model,
        logger: LoggerAgentProtocol,
        qrResolverFeatureFlag: QRResolverFeatureFlag = .init(.inactive)
    ) -> RootViewModel {
        
        let httpClient = model.authenticatedHTTPClient()
        
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
        
        let qrResolver: QRViewModel.QRResolver = { string in
            
            let isSberQR = qrResolverFeatureFlag.isActive ? model.isSberQR : { _ in false }
            let resolver = QRResolver(isSberQR: isSberQR)
            
            return resolver.resolve(string: string)
        }
        
        let makeQRScannerModel: MakeQRScannerModel = {
            
            .init(closeAction: $0, qrResolver: qrResolver)
        }
        
        let getSberQRDataService = Services.makeGetSberQRDataService(
            httpClient: httpClient
            // log: { logger.log(level: $0, category: .network, message: $1, file: $2, line: $3) }
        )
        
        let getSberQRData: GetSberQRData = getSberQRDataService.process
        
        let makeSberQRConfirmPaymentViewModel = SberQRConfirmPaymentViewModel.init
        
        let makeProductProfileViewModel = {
            
            ProductProfileViewModel(
                model,
                makeQRScannerModel: makeQRScannerModel,
                getSberQRData: getSberQRData,
                makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel,
                cvvPINServicesClient: cvvPINServicesClient,
                product: $0,
                rootView: $1,
                dismissAction: $2
            )
        }
        
        return make(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeQRScannerModel: makeQRScannerModel,
            getSberQRData: getSberQRData,
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel,
            onRegister: resetCVVPINActivation
        )
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
        makeQRScannerModel: @escaping MakeQRScannerModel,
        getSberQRData: @escaping GetSberQRData,
        makeSberQRConfirmPaymentViewModel: @escaping MakeSberQRConfirmPaymentViewModel,
        onRegister: @escaping OnRegister
    ) -> RootViewModel {
        
        let mainViewModel = MainViewModel(
            model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeQRScannerModel: makeQRScannerModel,
            getSberQRData: getSberQRData,
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel,
            onRegister: onRegister
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeQRScannerModel: makeQRScannerModel,
            getSberQRData: getSberQRData,
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel
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
