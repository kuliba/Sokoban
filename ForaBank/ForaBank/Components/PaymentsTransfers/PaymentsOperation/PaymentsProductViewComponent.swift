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
        
        private func bind() {
            
            selector.$content
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] content in
                    
                    if case let .product(productViewModel) = content {
                        
                        update(value: "\(productViewModel.id)")
                        
                    } else {
                        
                        update(value: nil)
                    }
   
                }.store(in: &bindings)
            
            $isEditable
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEditable in
                    
                    selector.context.value.isUserInteractionEnabled = isEditable
                    
                }.store(in: &bindings)
        }
        
        override func update(source: PaymentsParameterRepresentable) {
            super.update(source: source)
            
            guard let source = source as? Payments.ParameterProduct else {
                return
            }
            
            if let value = source.value,
               let IntValue = Int(value),
               let product = model.product(productId: IntValue) {
                
                let viewModel = ProductSelectorView.ViewModel.ProductViewModel(model, productData: product, context: .init(title: source.title, direction: .from, style: .regular, isUserInteractionEnabled: self.isEditable, filter: source.filter))
                
                self.selector.content = .product(viewModel)
                
            } else if let product = model.firstProduct(with: source.filter) {
                
                let viewModel = ProductSelectorView.ViewModel.ProductViewModel(model, productData: product, context: .init(title: source.title, direction: .from, style: .regular, isUserInteractionEnabled: self.isEditable, filter: source.filter))
                
                self.selector.content = .product(viewModel)
            }
            
            self.selector.context.value.filter = source.filter
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
            
            previewGroup()
            
            VStack(content: previewGroup)
                .previewDisplayName("Xcode 14")
        }
        .previewLayout(.sizeThatFits)
    }
    
    static func previewGroup() -> some View {
        
        Group {
            
            PaymentsProductView(viewModel: .sample)            
            PaymentsProductView(viewModel: .sampleExpanded)
        }
    }
}

//MARK: - Preview Content

extension PaymentsProductView.ViewModel {
    
    static let sample = PaymentsProductView.ViewModel(selector: .sampleMe2MeCollapsed)
    
    static let sampleExpanded = PaymentsProductView.ViewModel(selector: .sample2)
}



