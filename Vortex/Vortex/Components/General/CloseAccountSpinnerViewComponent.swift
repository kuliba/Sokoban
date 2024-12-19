//
//  CloseAccountSpinnerViewComponent.swift
//  Vortex
//
//  Created by Pavel Samsonov on 03.11.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension CloseAccountSpinnerView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        private let model: Model
        private let productData: ProductData
        
        private var bindings = Set<AnyCancellable>()

        init(_ model: Model, productData: ProductData) {
            
            self.model = model
            self.productData = productData
            
            bind()
        }
        
        private func bind() {
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case let payload as ModelAction.Account.Close.Response:
                        
                        switch payload {
                        case let .success(data: transferData):
                            
                            let currency = Currency(description: productData.currency)
                            let balance = productData.balanceValue
                            if let success = Payments.Success(
                                model: model,
                                mode: .closeAccountEmpty(
                                    productData.id,
                                    currency,
                                    balance: balance,
                                    transferData
                                ),
                                amountFormatter: model.amountFormatted(amount:currencyCode:style:)
                            ) {
                                
                                let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
                                self.action.send(CloseAccountSpinnerAction.Response.Success(viewModel: successViewModel))
                            }
                            
                        case let .failure(message: message):
                            self.action.send(CloseAccountSpinnerAction.Response.Failed(message: message))
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

struct CloseAccountSpinnerView: View {
    
    @ObservedObject var viewModel: CloseAccountSpinnerView.ViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            SpinnerRefreshView(icon: .init("Logo Vortex"))
        }
    }
}

// MARK: - Action

enum CloseAccountSpinnerAction {
    
    enum Response {
    
        struct Success: Action {
            
            let viewModel: PaymentsSuccessViewModel
        }
        
        struct Failed: Action {
            
            let message: String
        }
    }
}
