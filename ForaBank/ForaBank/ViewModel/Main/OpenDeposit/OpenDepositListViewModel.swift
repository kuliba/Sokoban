//
//  OpenDepositListViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import Foundation
import SwiftUI
import Combine

class OpenDepositListViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    @Published var offers: [OfferProductView.ViewModel]
    @Published var bottomSheet: BottomSheet?

    @Published private(set) var route: Route
    
    let catalogType: CatalogType
    let makeAlertViewModel: PaymentsTransfersFactory.MakeAlertViewModel
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(
        _ model: Model = .emptyMock,
        navigationBar: NavigationBarView.ViewModel,
        products offers: [OfferProductView.ViewModel],
        catalogType: CatalogType,
        route: Route = .empty,
        makeAlertViewModel: @escaping PaymentsTransfersFactory.MakeAlertViewModel
    ) {
        self.navigationBar = navigationBar
        self.catalogType = catalogType
        self.offers = offers
        self.model = model
        self.route = route
        self.makeAlertViewModel = makeAlertViewModel
    }
    
    init(
        _ model: Model,
        catalogType: CatalogType,
        route: Route = .empty,
        dismissAction: @escaping () -> Void,
        makeAlertViewModel: @escaping PaymentsTransfersFactory.MakeAlertViewModel
    ) {
        self.navigationBar = .init(title: "Вклады", leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: dismissAction)])
        self.model = model
        self.offers = []
        self.catalogType = catalogType
        self.route = route
        self.makeAlertViewModel = makeAlertViewModel
        
        bind()
        
        switch catalogType {
        case .deposit:
            self.model.action.send(ModelAction.Deposits.List.Request())

        case .catalog:
            self.model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.productCatalogList]))
        }
    }
    
    struct Route {
        
        var destination: Link?
        
        static let empty: Self = .init(destination: nil)
        
        enum Link: Identifiable {
            
            case openDeposit(OpenDepositDetailViewModel)
            
            var id: Case {
                
                switch self {
                case let .openDeposit(viewModel):
                    return .openDeposit(viewModel.id)
                }
            }
            
            enum Case: Hashable {
                
                case openDeposit(DepositProductData.ID)
            }
        }
    }
    
    private func bind() {
        
        switch catalogType {
        case .deposit:
            
            model.deposits
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] deposits in
                    
                    self.offers = deposits.map {
                        
                        OfferProductView.ViewModel(
                            with: $0,
                            openDeposit: orderButtonTapped
                        )
                    }
                    
                    requestDepositImages(for: deposits)
                    bind(self.offers)
                    
                }.store(in: &bindings)
            
        case .catalog:
            
            model.catalogProducts
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] products in
                    
                    self.offers = products.map {
                        
                        OfferProductView.ViewModel(
                            with: $0,
                            openDeposit: orderButtonTapped
                        )
                    }
                    
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
    
    func orderButtonTapped(depositID: DepositProductData.ID?) {
        
        if let depositID,
           let openDepositViewModel = OpenDepositDetailViewModel(depositId: depositID, model: model, makeAlertViewModel: makeAlertViewModel) {
            
            route.destination = .openDeposit(openDepositViewModel)
        }
    }

    func resetDestination() {
        
        route.destination = nil
    }
}

extension OpenDepositListViewModel {
    
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
