//
//  PaymentsServicesView.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.02.2022.
//

import SwiftUI
import Combine

struct PaymentsServicesView: View {
    
    @ObservedObject var viewModel: PaymentsServicesViewModel
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                ScrollView {
                    
                    if let selectViewModel = viewModel.select {
                        
                        PaymentsParameterSelectServiceView(viewModel: selectViewModel)
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
}

//MARK: - Preview

struct PaymentsServicesView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsServicesView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

//MARK: - Preview Content

extension PaymentsServicesViewModel {
    
    static let sample = PaymentsServicesViewModel(header: .init(title: "Налоги и услуги"), select: .samplePlaceholder, category: .taxes)
}
