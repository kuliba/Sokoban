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
                    VStack(spacing: 20) {
                        ForEach(viewModel.items) {item in
                            
                            
                            NavigationLink(isActive: $viewModel.isPaymentViewActive) {
                                if let operationViewModel = viewModel.operationViewModel {
                                    PaymentsOperationView(viewModel: operationViewModel)
                                } else {
                                    EmptyView()
                                }
                            } label: {
                                Button {
                                    item.action(item.id)

                                } label: {
                                        PaymentsTaxesButtonInfoCellView(viewModel: item)
                                }
                            }
                        }
                    }
                } .padding(.top, 10)
                  .padding(.horizontal, 15)
            }
            .navigationBarTitle(Text(viewModel.header?.title ?? ""), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Image("back_button")
                                    .renderingMode(.template)
                                    .foregroundColor(.black)
                                
//                                    .onTapGesture {
//                self.presentation.wrappedValue.dismiss()
//            })
                                )
    }
}
}

struct PaymentsServicesView_Previews: PreviewProvider {
        static var previews: some View {
            PaymentsServicesView(viewModel: .init(model: .emptyMock, category: .taxes, items: [.init(icon: Image(""), title: "ФМС", subTitle: "налоги", action: { _ in
            })], header: nil, isPaymentViewActive: false))
    }
}
                                    
                                    
                                    
