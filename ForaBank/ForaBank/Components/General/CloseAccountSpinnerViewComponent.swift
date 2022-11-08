//
//  CloseAccountSpinnerViewComponent.swift
//  ForaBank
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
        
        var productId: ProductData.ID {
            productData.id
        }
        
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

                            let balance = productData.balanceValue
                            
                            let documentStatus: TransferResponseBaseData.DocumentStatus? = .init(rawValue: transferData.documentStatus)
                            
                            if let documentStatus = documentStatus, let paymentOperationDetailId = transferData.paymentOperationDetailId {
                                
                                let responseData: TransferResponseData = .init(amount: balance, creditAmount: nil, currencyAmount: .init(description: productData.currency), currencyPayee: nil, currencyPayer: .init(description: productData.currency), currencyRate: nil, debitAmount: balance, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId)
                                
                                let successMeToMe: PaymentsSuccessViewModel = .init(model, mode: .closeAccountEmpty(productData.id), state: .success(documentStatus, paymentOperationDetailId), responseData: responseData)

                                self.action.send(CloseAccountSpinnerAction.Response.Success(viewModel: successMeToMe))
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
            
            SpinnerRefreshView(icon: .init("Logo Fora Bank"))
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
