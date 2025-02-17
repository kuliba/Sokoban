//
//  PaymentsServiceView.swift
//  Vortex
//
//  Created by Константин Савялов on 15.02.2022.
//

import Combine
import SwiftUI
import UtilityServicePrepaymentUI

struct PaymentsServiceViewFactory {
    
    let makePaymentsOperationView: MakePaymentsOperationView
}

struct PaymentsServiceView: View {
    
    @ObservedObject var viewModel: PaymentsServiceViewModel
    
    // deep tree structure prevents injection, need parameter
    let isRounded: Bool
    
    let viewFactory: PaymentsServiceViewFactory
    
    var body: some View {
        
        if isRounded {
            scrollView()
        } else {
            scrollView()
                .navigationBar(with: viewModel.navigationBar)
        }
    }
    
    private func scrollView() -> some View {
        
        ScrollView {
            
            ForEach(viewModel.content, content: itemView)
            navigationLink()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func itemView(
        _ viewModel: PaymentsParameterViewModel
    ) -> some View {
        
        switch viewModel {
        case let viewModel as PaymentsSelectServiceView.ViewModel:
            itemView(viewModel)
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func itemView(
        _ viewModel: PaymentsSelectServiceView.ViewModel
    ) -> some View {
        
        if isRounded {
            withRoundedItems(viewModel)
        } else {
            PaymentsSelectServiceView(viewModel: viewModel)
        }
    }
    
    private func withRoundedItems(
        _ viewModel: PaymentsSelectServiceView.ViewModel
    ) -> some View {
        
        VStack(spacing: 16) {
            
            ForEach(viewModel.items, content: button)
        }
    }
    
    private func button(
        viewModel: PaymentsSelectServiceView.ViewModel.ItemViewModel
    ) -> some View {
        
        Button {
            viewModel.action(viewModel.service)
        } label: {
            operatorLabel(viewModel)
        }
    }
            
    private func operatorLabel(
        _ viewModel: PaymentsSelectServiceView.ViewModel.ItemViewModel
    ) -> some View {
        
        OperatorLabel(
            title: viewModel.title,
            subtitle: viewModel.subTitle,
            config: .iVortex(
                chevron: .iVortex,
                subtitleFont: .textBodySR12160()
            ),
            iconView: {
                
                viewModel.icon
                    .resizable()
                    .foregroundStyle(.orange)
            }
        )
        .paddedRoundedBackground()
    }
        
    private func navigationLink(
    ) -> some View {
        
        NavigationLink("", isActive: $viewModel.isLinkActive) {
            
            if let link = viewModel.link  {
                
                switch link {
                case let .operation(operationViewModel):
                    viewFactory.makePaymentsOperationView(operationViewModel)
                }
            }
        }
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
