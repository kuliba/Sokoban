//
//  PaymentsCardViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsProductView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let selector: ProductSelectorView.ViewModel
        
        private let model: Model

        init(selector: ProductSelectorView.ViewModel, model: Model = .emptyMock, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.selector = selector
            self.model = model
            super.init(source: source)
        }

        convenience init(_ model: Model, parameterProduct: Payments.ParameterProduct) {
            
            let selector = ProductSelectorView.ViewModel(model, parameterProduct: parameterProduct)
            self.init(selector: selector, model: model, source: parameterProduct)
            
            bind()
        }
        
        internal func bind() {
            
            
        }
    }
}

//MARK: - View

struct PaymentsProductView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        ProductSelectorView(viewModel: viewModel.selector)
    }
}

//MARK: - Preview

struct PaymentsCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsProductView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 90))
            
            PaymentsProductView(viewModel: .sampleExpanded)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension PaymentsProductView.ViewModel {
    
    static let sample = PaymentsProductView.ViewModel(selector: .sampleMe2MeCollapsed)
    
    static let sampleExpanded = PaymentsProductView.ViewModel(selector: .sample2)
}



