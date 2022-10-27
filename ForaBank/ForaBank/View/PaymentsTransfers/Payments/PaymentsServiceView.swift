//
//  PaymentsServiceView.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.02.2022.
//

import SwiftUI
import Combine

struct PaymentsServiceView: View {
    
    @ObservedObject var viewModel: PaymentsServiceViewModel
    
    var body: some View {
        
        VStack {
            
            ScrollView {
                
                if let selectViewModel = viewModel.select {
                    
                    PaymentsSelectServiceView(viewModel: selectViewModel)
                }
                
                NavigationLink("", isActive: $viewModel.isOperationViewActive) {
                    
                    if let operationViewModel = viewModel.operationViewModel {
                        
                        PaymentsOperationView(viewModel: operationViewModel)
                        
                    } else {
                        
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationBarTitle(Text(viewModel.header.title), displayMode: .inline)
    }
}

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
