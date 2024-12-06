//
//  PaymentsServiceView.swift
//  Vortex
//
//  Created by Константин Савялов on 15.02.2022.
//

import SwiftUI
import Combine

struct PaymentsServiceViewFactory {
    
    let makePaymentsOperationView: MakePaymentsOperationView
}

struct PaymentsServiceView: View {
    
    @ObservedObject var viewModel: PaymentsServiceViewModel
    let viewFactory: PaymentsServiceViewFactory
    
    var body: some View {
        
        VStack {
            
            ScrollView {
                
                ForEach(viewModel.content) { itemViewModel in
                    
                    switch itemViewModel {
                    case let selectServiceViewModel as PaymentsSelectServiceView.ViewModel:
                        PaymentsSelectServiceView(viewModel: selectServiceViewModel)
                     
                    default:
                        Color.clear
                    }
                }

                NavigationLink("", isActive: $viewModel.isLinkActive) {
                    
                    if let link = viewModel.link  {
                        
                        switch link {
                        case let .operation(operationViewModel):
                            viewFactory.makePaymentsOperationView(operationViewModel)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationBar(with: viewModel.navigationBar)
    }
}

/*
//MARK: - Preview

struct PaymentsServicesView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsServiceView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

//MARK: - Preview Content

extension PaymentsServiceViewModel {
    
    static let sample = PaymentsServiceViewModel(header: .init(title: "Налоги и услуги"), parameter: .init(category: .taxes, options: []))
}
 */
