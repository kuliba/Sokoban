//
//  PaymentsInfoGroupView.swift
//  ForaBank
//
//  Created by Max Gribov on 22.02.2023.
//

import SwiftUI

struct PaymentsInfoGroupView: View {
    
    let viewModel: PaymentsInfoGroupViewModel
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            ForEach(viewModel.items) { itemViewModel in
                
                itemView(for: itemViewModel)
                    .frame(minHeight: 20)
            }
        }
        .padding(.vertical, 13)
        .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsGrayLightest))
        .padding(.horizontal, 16)
    }
}

extension PaymentsInfoGroupView {
    
    @ViewBuilder
    func itemView(for viewModel: PaymentsParameterViewModel) -> some View {
        
        switch viewModel {
        case let infoViewModel as PaymentsInfoView.ViewModel:
            PaymentsInfoView(viewModel: infoViewModel, isCompact: true)
       
        default:
            EmptyView()
        }
    }
}

//MARK: - Preview

struct PaymentsInfoGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        PaymentsInfoGroupView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

//MARK: - Preview Content

extension PaymentsInfoGroupViewModel {
    
    static let sample = PaymentsInfoGroupViewModel(items: [
        PaymentsInfoView.ViewModel.sampleGroupOne,
        PaymentsInfoView.ViewModel.sampleGroupTwo,
        PaymentsInfoView.ViewModel.sampleGroupThree,
        PaymentsInfoView.ViewModel.sampleGroupFour,
    ])
}
