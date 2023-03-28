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
            
            switch viewModel.content {
            case let .service(serviceViewModel):
                PaymentsServiceView(viewModel: serviceViewModel)
                    .zIndex(0)
                    .navigationBarItems(leading: Button(action: { viewModel.action.send(PaymentsViewModelAction.Dismiss())}, label: {
                        Image("Payments Icon Close") }))
                
            case let .operation(operationViewModel):
                PaymentsOperationView(viewModel: operationViewModel)
                    .zIndex(0)
            }
            
            if let spinnerViewModel = viewModel.spinner {
                
                SpinnerView(viewModel: spinnerViewModel)
                    .zIndex(1)
            }
            
            Color.clear
                .fullScreenCover(item: $viewModel.successViewModel, content: { successViewModel in
                    
                    PaymentsSuccessView(viewModel: successViewModel)
                })
            
            Color.clear
                .alert(item: $viewModel.alert, content: { alertViewModel in
                    
                    Alert(with: alertViewModel)
                })
        }
        .navigationBarBackButtonHidden(true)
    }
}

//MARK: - Preview

struct PaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension PaymentsViewModel {
    
    static let sample = PaymentsViewModel(content: .service(.init(header: .init(title: "test"), content: [], link: nil, model: .emptyMock)), category: .general, model: .emptyMock, closeAction: {})
}
