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
        
        Group {
            
            switch viewModel.content {
            case .services(let servicesViewModel):
                NavigationView {
                    PaymentsServicesView(viewModel: servicesViewModel)
                }
                
            case .operation(let operationViewModel):
                NavigationLink("", isActive: .constant(true)) {
                    PaymentsOperationView(viewModel: operationViewModel)
                }
                
            case .idle:
                Text("Loading..")
            }
        }
        .fullScreenCoverLegacy(viewModel: $viewModel.successViewModel) { successViewModel in
            PaymentsSuccessView(viewModel: successViewModel)
        }
    }
}

struct PaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsView(viewModel: .sample)
    }
}

extension PaymentsViewModel {
    
    static let sample = PaymentsViewModel(.emptyMock, category: .taxes)
}
