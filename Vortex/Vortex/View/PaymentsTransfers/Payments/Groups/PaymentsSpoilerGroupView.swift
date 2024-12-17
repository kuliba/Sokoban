//
//  PaymentsSpoilerGroupView.swift
//  ForaBank
//
//  Created by Max Gribov on 22.02.2023.
//

import SwiftUI

struct PaymentsSpoilerGroupView: View {
    
    @ObservedObject var viewModel: PaymentsSpoilerGroupViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if viewModel.isCollapsed == false {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    itemView(for: itemViewModel)
                        .frame(minHeight: 72)
                }
            }
            
            PaymentsSpoilerButtonView(viewModel: viewModel.button)
        }
        .padding(.top, topPadding)
        .padding(.bottom, 13)
        .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsGrayLightest))
        .padding(.horizontal, 16)
    }
}

extension PaymentsSpoilerGroupView {
    
    @ViewBuilder
    func itemView(for viewModel: PaymentsParameterViewModel) -> some View {
        
        switch viewModel {
        case let infoViewModel as PaymentsInfoView.ViewModel:
            PaymentsInfoView(viewModel: infoViewModel)
       
        default:
            EmptyView()
        }
    }
    
    var topPadding: CGFloat {
        
        viewModel.isCollapsed ? 13 : 0
    }
}

struct PaymentsSpoilerGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsSpoilerGroupView(viewModel: .sampleExpanded)
            .previewLayout(.fixed(width: 375, height: 500))
        
        PaymentsSpoilerGroupView(viewModel: .sampleCollapsed)
            .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension PaymentsSpoilerGroupViewModel {
    
    static let sampleExpanded = PaymentsSpoilerGroupViewModel(items: [
        PaymentsInfoView.ViewModel.sampleGroupOne,
        PaymentsInfoView.ViewModel.sampleGroupTwo,
        PaymentsInfoView.ViewModel.sampleGroupThree,
        PaymentsInfoView.ViewModel.sampleGroupFour,
    ], isCollapsed: false, button: .init(title: "Дополнительно", isSelected: false))
    
    static let sampleCollapsed = PaymentsSpoilerGroupViewModel(items: [
        PaymentsInfoView.ViewModel.sampleGroupOne,
        PaymentsInfoView.ViewModel.sampleGroupTwo,
        PaymentsInfoView.ViewModel.sampleGroupThree,
        PaymentsInfoView.ViewModel.sampleGroupFour,
    ], isCollapsed: false, button: .init(title: "Дополнительно", isSelected: true))
}
