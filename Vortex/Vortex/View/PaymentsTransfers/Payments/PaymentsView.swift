//
//  PaymentsView.swift
//  Vortex
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
                SpinnerRefreshView(icon: Image("Logo Vortex"))
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
                .fullScreenCover(
                    item: .init(
                        get: { viewModel.route?.fullScreen },
                        set: { if $0 == nil { viewModel.dismiss() }}
                    ),
                    content: fullScreenContent
                )

            Color.clear
                .navigationDestination(
                    item: .init(
                        get: { viewModel.route?.destination },
                        set: { _ in } // managed by action in content
                    ),
                    content: destinationContent
                )
            
            Color.clear
                .zIndex(3)
                .alert(item: $viewModel.alert, content: { alertViewModel in
                    
                    Alert(with: alertViewModel)
                })
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    func fullScreenContent(
        _ fullScreen: PaymentsViewModel.Route.FullScreen
    ) -> some View {
        
        switch fullScreen {
        case let .success(successViewModel):
            viewFactory.makePaymentsSuccessView(successViewModel)
        }
    }
    
    @ViewBuilder
    func destinationContent(
    _ destination: PaymentsViewModel.Route.Destination
    ) -> some View {
        
        switch destination {
        case let .confirm(confirmViewModel):
            viewFactory.makePaymentsOperationView(confirmViewModel)
        }
    }
}

extension PaymentsViewModel.Route {
        
    var destination: Destination? {
        
        switch self {
        case let .confirm(confirm):
            return .confirm(confirm)
            
        default:
            return nil
        }
    }
    
    enum Destination {
        
        case confirm(PaymentsConfirmViewModel)
    }
    
    var fullScreen: FullScreen? {
        
        switch self {
        case let .success(success):
            return .success(success)
            
        default:
            return nil
        }
    }
    
    enum FullScreen {
        
        case success(PaymentsSuccessViewModel)
    }
}

extension PaymentsViewModel.Route.Destination: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
        case let .confirm(confirm):
            return .init(confirm)
        }
    }
}

extension PaymentsViewModel.Route.FullScreen: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
        case let .success(success):
            return .init(success)
        }
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
