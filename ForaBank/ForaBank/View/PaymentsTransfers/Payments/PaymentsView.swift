//
//  PaymentsView.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2022.
//

import SwiftUI

struct PaymentsViewFactory {
    
    let makePaymentsOperationView: MakePaymentsOperationView
    let makePaymentsServiceView: MakePaymentsServiceView
    let makePaymentsSuccessView: MakePaymentsSuccessView
}

extension PaymentsViewFactory {
    
    static let preview: Self = .init(
        makePaymentsOperationView: {_ in fatalError()},
        makePaymentsServiceView: {_ in fatalError()},
        makePaymentsSuccessView: {_ in fatalError()})
}

struct PaymentsView: View {
    
    @ObservedObject var viewModel: PaymentsViewModel
    let viewFactory: PaymentsViewFactory
    
    var body: some View {
        
        ZStack {
            
            switch viewModel.content {
            case .loading:
                //TODO: load image from StyleGuide
                SpinnerRefreshView(icon: Image("Logo Fora Bank"))
                    .zIndex(0)
                
            case let .service(serviceViewModel):
                viewFactory.makePaymentsServiceView(serviceViewModel)
                    .zIndex(0)
                    .navigationBarItems(leading: Button(action: { viewModel.action.send(PaymentsViewModelAction.Dismiss())}, label: {
                        Image("Payments Icon Close") }))
             
            case let .operation(node):
                viewFactory.makePaymentsOperationView(node.model)
                    .zIndex(0)

            case let .linkNotActive(viewModel):
                viewFactory.makePaymentsSuccessView(viewModel)
            }
            
            if let spinnerViewModel = viewModel.spinner {
                
                SpinnerView(viewModel: spinnerViewModel)
                    .zIndex(1)
            }
            
            Color.clear
                .zIndex(2)
                .fullScreenCover(item: $viewModel.successViewModel, content: { successViewModel in
                    
                    viewFactory.makePaymentsSuccessView(successViewModel)
                })
            
            Color.clear
                .zIndex(3)
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
        
        PaymentsView(viewModel: .sample, viewFactory: .preview)
    }
}

//MARK: - Preview Content

extension PaymentsViewModel {
    
    static let sample = PaymentsViewModel(content: .service(.init(navigationBar: .init(title: "Test"), content: [], link: nil, model: .emptyMock)), model: .emptyMock, closeAction: {})
}
