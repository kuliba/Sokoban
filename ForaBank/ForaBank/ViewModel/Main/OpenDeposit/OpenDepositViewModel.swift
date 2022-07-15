//
//  OpenDepositViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import Foundation
import SwiftUI
import Combine

class OpenDepositViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navButtonBack: NavigationBarButtonViewModel
    @Published var products: [OfferProductView.ViewModel]
    @Published var bottomSheet: BottomSheet?

    let catalogType: CatalogType
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    
    init(_ model: Model = .emptyMock, navButtonBack: NavigationBarButtonViewModel, products: [OfferProductView.ViewModel], catalogType: CatalogType) {
        
        self.navButtonBack = navButtonBack
        self.catalogType = catalogType
        self.products = products
        self.model = model
    }
    
    init(_ model: Model, catalogType: CatalogType, dismissAction: @escaping () -> Void) {
        
        self.navButtonBack = .init(icon: .ic24ChevronLeft, action: dismissAction)
        self.model = model
        self.products = []
        self.catalogType = catalogType
        
        bind()
        
        switch catalogType {
        case .deposit:
            self.model.action.send(ModelAction.Deposits.List.Request())

        case .catalog:
            self.model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.productCatalogList]))
        
        }

    }
    
    private func bind() {
        
        switch catalogType {
        case .deposit:
            
            model.deposits
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] deposits in
                    
                    self.products = deposits.map { OfferProductView.ViewModel(with: $0) }
                    
                    requestDepositImages(for: deposits)
                    bind(self.products)
                    
                }.store(in: &bindings)
            
        case .catalog:
            
            model.catalogProducts
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] products in
                    
                    self.products = products.map { OfferProductView.ViewModel(with: $0) }
                    
                    requestImages(for: products)
                    bind(self.products)

                }.store(in: &bindings)
                
        }
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as OperationDetailViewModelAction.Dismiss:
                    self.action.send(OperationDetailViewModelAction.Dismiss())
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.General.DownloadImage.Response:
                    switch payload.result {
                    case .success(let data):
                        
                        guard let image = Image(data: data) else {
                            //TODO: log
                            print("AuthProductsViewModel: unable create product image from data for endpoint: \(payload.endpoint)")
                            return
                        }
                        
                        guard let productCard = products.first(where: { productCard in
                            
                            guard case .endpoint(let endpoint) = productCard.image else {
                                return false
                            }
                            
                            return endpoint == payload.endpoint
                            
                        }) else {
                            
                            return
                        }
                        
                        withAnimation {
                            
                            productCard.image = .image(image)
                        }
                        
                    case .failure(let error):
                        //TODO: log
                        print("AuthProductsViewModel: product image download failed for endpoint: \(payload.endpoint) with error: \(error.localizedDescription)")
                    }
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ products: [OfferProductView.ViewModel]) {
        
        for product in products {
            
            product.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    switch action {
                        
                    case _ as ModelActionOpenDeposit.ButtonTapped:
                        if let additionalCondition = product.additionalCondition {
                            bottomSheet = .init(.init(type: .openDeposit(.init(desc: additionalCondition.desc))))
                        }
                        
                    default: break
                    }
                }.store(in: &bindings)
        }
    }
    
    func requestImages(for products: [CatalogProductData]) {
        
        for product in products {
            
            model.action.send(ModelAction.General.DownloadImage.Request(endpoint: product.imageEndpoint))
        }
    }
    
    func requestDepositImages(for products: [DepositProductData]) {
        
        for product in products {
            
            model.action.send(ModelAction.General.DownloadImage.Request(endpoint: product.generalСondition.imageLink))
        }
    }
}

extension OpenDepositViewModel {
    
    struct BottomSheet: Identifiable {

        let id = UUID()
        let type: BottomSheetType

        enum BottomSheetType {

            case openDeposit(OfferProductView.ViewModel.AdditionalCondition)
        }
    }
    
    enum CatalogType {
        case deposit
        case catalog
    }
    
    enum ModelActionOpenDeposit {
        
        struct ButtonTapped: Action {}
    }
}
