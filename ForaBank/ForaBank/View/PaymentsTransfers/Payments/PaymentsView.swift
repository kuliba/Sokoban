//
//  PaymentsView.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2022.
//

import SwiftUI

struct PaymentsView: View {
    
    @ObservedObject var viewModel: PaymentsViewModel
    
    var body: some View {
        
        ZStack {
            
            NavigationView {
                
                switch viewModel.content {
                case let .service(serviceViewModel):
                    PaymentsServiceView(viewModel: serviceViewModel)
                        .navigationBarItems(leading: Button(action: { viewModel.action.send(PaymentsViewModelAction.Dismiss())}, label: {
                            Image("Payments Icon Close") }))
                    
                case let .operation(operationViewModel):
                    PaymentsOperationView(viewModel: operationViewModel)
                }
            }
            
            if let spinnerViewModel = viewModel.spinner {
                
                SpinnerView(viewModel: spinnerViewModel)
            }
        }
        .fullScreenCover(item: $viewModel.successViewModel, content: { successViewModel in
            
            PaymentsSuccessView(viewModel: successViewModel)
        })
        .alert(item: $viewModel.alert, content: { alertViewModel in
            
            Alert(with: alertViewModel)
        })
    }
}

//TODO: refactor
/*
struct PaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsView(viewModel: .sample)
    }
}

extension PaymentsViewModel {
    
    static let sample = PaymentsViewModel(content: .idle, category: .taxes, model: .emptyMock, closeAction: {})
}
 */
