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
    
    @Published var products: [OfferProductView.ViewModel]
    @Published var isShowSheet: Bool = false
    
    let style: Style
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    
    init(_ model: Model = .emptyMock, products: [OfferProductView.ViewModel], dismissAction: @escaping () -> Void = {}, style: Style) {
        
        self.style = style
        self.products = products
        self.model = model
    }
    
    init(_ model: Model, products: [CatalogProductData], dismissAction: @escaping () -> Void = {}, style: Style) {
        
        self.style = .catalog
        self.products = products.enumerated().map({ product in
            
            OfferProductView.ViewModel(with: product.element)
        })
        self.model = model
        
        bind()
        self.model.action.send(ModelAction.Deposits.List.Request())
        requestImages(for: products)
    }
    
    init(_ model: Model, products: [DepositProductData], dismissAction: @escaping () -> Void = {}, style: Style) {
        
        self.style = .deposit
        self.products = products.enumerated().map({ product in
            
            OfferProductView.ViewModel(with: product.element, action: dismissAction)
        })
        self.model = model
        
        bind()
        requestDepositImages(for: products)
        self.model.action.send(ModelAction.Deposits.List.Request())
    }
    
    private func bind() {
        
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
                case let payload as ModelAction.Auth.ProductImage.Response:
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
    
    func requestImages(for products: [CatalogProductData]) {
        
        for product in products {
            
            model.action.send(ModelAction.Auth.ProductImage.Request(endpoint: product.imageEndpoint))
        }
    }
    
    func requestDepositImages(for products: [DepositProductData]) {
        
        for product in products {
            
            model.action.send(ModelAction.Auth.ProductImage.Request(endpoint: product.generalСondition.imageLink))
        }
    }
}

extension OpenDepositViewModel {
    
    enum Style {
        case deposit
        case catalog
    }
}

