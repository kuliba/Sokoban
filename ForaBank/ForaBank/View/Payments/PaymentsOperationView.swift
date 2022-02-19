//
//  PaymentsOperationViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.02.2022.
//

import SwiftUI
import Combine

struct PaymentsOperationView: View {
    
    @ObservedObject var viewModel: PaymentsOperationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.items) {item in
                    parameterView(viewModel: item)
                }
            }
        } .padding(.top, 10)
            .padding(.horizontal, 15)
    }
    
}

extension PaymentsOperationView {
    
    func parameterView (viewModel: PaymentsParameterViewModel) -> AnyView {
        switch viewModel {
        case let selectViewModel as PaymentsTaxesSelectCellView.ViewModel:
            return AnyView(PaymentsTaxesSelectCellView(viewModel: selectViewModel))
            
        case let hiddenViewModel as PaymentsTaxesSelectCellView.ViewModel:
            return AnyView(EmptyView())
            
        case let selectSimpleViewModel as PaymentsTaxesButtonInfoCellView.ViewModel:
            return AnyView(PaymentsTaxesButtonInfoCellView(viewModel: selectSimpleViewModel))
            
        case let selectSwitchViewModel as PaymentsTaxesParameterSwitchViewModel:
            return AnyView(PaymentsTaxesParameterSwitchView(viewModel: selectSwitchViewModel))
            
        case let inputViewModel as PaymentsTaxesInputCellView.ViewModel:
            return AnyView(PaymentsTaxesInputCellView(viewModel: inputViewModel))
            
        case let infoViewModel as PaymentsTaxesInfoCellViewComponent.ViewModel:
            return AnyView(PaymentsTaxesInfoCellViewComponent(viewModel: infoViewModel))
            
        case let nameViewModel as PaymentsParameterFullNameView.ViewModel:
            return AnyView(PaymentsParameterFullNameView(viewModel: nameViewModel))
            
        case let amountViewModel as PaymentsTaxesSelectCellView.ViewModel:
            return AnyView(EmptyView())
            
        case let cardViewModel as PaymentsTaxesSelectCellView.ViewModel:
            return AnyView(EmptyView())
        default:
            return AnyView(EmptyView())
        }
    }
    
}

struct PaymentsOperationView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsOperationView(viewModel: .init(model: .emptyMock, category: .taxes, items: [], header: nil))
    }
}
