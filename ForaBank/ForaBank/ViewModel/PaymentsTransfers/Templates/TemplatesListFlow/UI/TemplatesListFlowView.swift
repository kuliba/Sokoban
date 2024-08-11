//
//  TemplatesListFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import SwiftUI

struct TemplatesListFlowView: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        
        TemplatesListView(viewModel: model.state.content)
    }
}

extension TemplatesListFlowView {
    
    typealias Model = TemplatesListFlowModel<TemplatesListViewModel>
}

extension TemplatesListViewModel: ProductIDEmitter {
    
    var productIDPublisher: AnyPublisher<ProductID, Never> {
        
        action
            .compactMap { $0 as? TemplatesListViewModelAction.OpenProductProfile }
            .map(\.productId)
            .eraseToAnyPublisher()
    }
}
