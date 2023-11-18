//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Foundation
import PaymentSticker

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
        
        let makeOperationStateViewModel: MakeOperationStateViewModel = {
            
            let dictionaryService = Services.makeGetStickerDictService(
                httpClient: httpClient
            )
            let transferService = Services.makeCommissionProductTransferService(
                httpClient: httpClient
            )
            let makeTransferService = Services.makeTransferService(
                httpClient: httpClient
            )
            let makeImageLoaderService = Services.makeImageListService(
                httpClient: httpClient
            )
            let processImageLoader = Services.makeImageListService(
                httpClient: httpClient
            )
            
            return OperationStateViewModel(businessLogic: .init(
                processDictionaryService: dictionaryService.process,
                processTransferService: transferService.process,
                processMakeTransferService: makeTransferService.process,
                processImageLoaderService: makeImageLoaderService.process,
                selectOffice: $0,
                products: model.productsMapper(model: model),
                cityList: model.citiesMapper(model: model)
            ))
        }
        
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
            makeOperationStateViewModel: makeOperationStateViewModel,
            makeProductProfileViewModel: makeProductProfileViewModel,
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
    
    typealias MakeOperationStateViewModel = (@escaping BusinessLogic.SelectOffice) -> OperationStateViewModel
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnRegister = () -> Void
    
    static func make(
        model: Model,
        makeOperationStateViewModel: @escaping MakeOperationStateViewModel,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        onRegister: @escaping OnRegister
    ) -> RootViewModel {
        
        let mainViewModel = MainViewModel(
            model,
            sections: makeMainSections(model: model),
            makeOperationStateViewModel: makeOperationStateViewModel,
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

private extension Model {
    
    func productsMapper(
        model: Model
    ) -> [BusinessLogic.Product] {
        
        let allProducts = model.allProducts.map({ BusinessLogic.Product(
            title: "Счет списания",
            nameProduct: $0.displayName,
            balance: $0.balanceValue.description,
            description: $0.displayNumber ?? "",
            cardImage: PaymentSticker.ImageData.data($0.smallDesign.uiImage?.pngData()),
            paymentSystem: PaymentSticker.ImageData.data($0.paymentSystemData),
            backgroundImage: PaymentSticker.ImageData.data($0.largeDesign.uiImage?.pngData()),
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
