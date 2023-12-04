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
        logger: LoggerAgentProtocol
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
        
        let qrResolver: QRViewModel.QRResolver = QRViewModel.ScanResult.init
        
        let makeQRScannerModel: MakeQRScannerModel = {
            
            .init(closeAction: $0, qrResolver: qrResolver)
        }
        
        let makeProductProfileViewModel = {
            
            ProductProfileViewModel(
                model,
                makeQRScannerModel: makeQRScannerModel,
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
            onRegister: resetCVVPINActivation
        )
    }
}

// Mocks for Sber QR with the shape of `QRViewModel.QRResolver`
private func fail(
    _ string: String = UUID().uuidString
) -> QRViewModel.ScanResult {
    
    .sberQR(.init(string: "https://platiqr.ru/?fail")!)
}

private func withAmount(
    _ string: String = UUID().uuidString
) -> QRViewModel.ScanResult {
    
    .sberQR(.init(string: "https://platiqr.ru/?uuid=22428")!)
}

private func withoutAmount(
    _ string: String = UUID().uuidString
) -> QRViewModel.ScanResult {

    .sberQR(.init(string: "https://platiqr.ru/?uuid=1000101124")!)
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
    typealias MakeQRScannerModel = (@escaping () -> Void) -> QRViewModel
    typealias GetSberQRDataCompletion = (Result<Data, Error>) -> Void
    typealias GetSberQRData = (URL, @escaping GetSberQRDataCompletion) -> Void
    typealias OnRegister = () -> Void
    
    static func make(
        model: Model,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        makeQRScannerModel: @escaping MakeQRScannerModel,
        onRegister: @escaping OnRegister
    ) -> RootViewModel {
        
        let getSberQRData = getSberQRDataStub
        
        let mainViewModel = MainViewModel(
            model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeQRScannerModel: makeQRScannerModel,
            getSberQRData: getSberQRData,
            onRegister: onRegister
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeQRScannerModel: makeQRScannerModel
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
    
    private static func getSberQRDataStub(
        url: URL,
        completion: @escaping GetSberQRDataCompletion
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            if url.absoluteString.contains("fail") {
                completion(.failure(NSError(domain: "GetSberQRData Failure", code: -1)))
            } else {
                completion(.success(.init()))
            }
        }
    }
}
