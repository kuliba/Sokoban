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
    
    let navigationBar: NavigationBarView.ViewModel
    @Published var offers: [OfferProductView.ViewModel]
    @Published var bottomSheet: BottomSheet?

    let catalogType: CatalogType
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    
    init(_ model: Model = .emptyMock, navigationBar: NavigationBarView.ViewModel, products offers: [OfferProductView.ViewModel], catalogType: CatalogType) {
        
        self.navigationBar = navigationBar
        self.catalogType = catalogType
        self.offers = offers
        self.model = model
    }
    
    init(_ model: Model, catalogType: CatalogType, dismissAction: @escaping () -> Void) {
        
        self.navigationBar = .init(title: "Вклады", leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: dismissAction)])
        self.model = model
        self.offers = []
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
                    
                    self.offers = deposits.map(OfferProductView.ViewModel.init(with:))
                    
                    requestDepositImages(for: deposits)
                    bind(self.offers)
                    
                }.store(in: &bindings)
            
        case .catalog:
            
            model.catalogProducts
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] products in
                    
                    self.offers = products.map { OfferProductView.ViewModel(with: $0) }
                    
                    requestImages(for: products)
                    bind(self.offers)

                }.store(in: &bindings)
                
        }
        
        action
            .compactMap { $0 as? OperationDetailViewModelAction.Dismiss }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                self.action.send(OperationDetailViewModelAction.Dismiss())
            }
            .store(in: &bindings)
        
        model.action
            .compactMap { $0 as? ModelAction.General.DownloadImage.Response }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] response in
                
                switch response.result {
                case let .success(data):
                    
                    guard let image = Image(data: data) else {
                        //TODO: set logger
                        return
                    }
                    
                    guard let productCard = offers.first(where: { productCard in
                        
                        guard case let .endpoint(endpoint) = productCard.image
                        else { return false }
                        
                        return endpoint == response.endpoint
                        
                    })
                    else { return }
                    
                    withAnimation {
                        
                        productCard.image = .image(image)
                    }
                    
                case let .failure(error):
                    //TODO: set logger
                    break
                }
            }
            .store(in: &bindings)
    }
    
    private func bind(_ offers: [OfferProductView.ViewModel]) {
        
        for offer in offers {
            
            offer.action
                .compactMap { $0 as? ModelActionOpenDeposit.ButtonTapped }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    if let additionalCondition = offer.additionalCondition {
                        
                        bottomSheet = .init(.init(type: .openDeposit(.init(desc: additionalCondition.desc))))
                    }
                }
                .store(in: &bindings)
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
    
    struct BottomSheet: BottomSheetCustomizable {

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
