//
//  MyProductsOpenProductComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 26.09.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension MyProductsOpenProductView {

    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()

        @Published var newProducts: OpenNewProductsViewModel

        let title = "Открыть продукт"
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()

        init(newProducts: OpenNewProductsViewModel, model: Model = .emptyMock) {
            
            self.newProducts = newProducts
            self.model = model
        }
        
        init(_ model: Model) {
            
            self.newProducts = .init(model)
            self.model = model
            
            bind()
        }
        
        func bind() {
            
            newProducts.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    switch action {
                    case let payload as OpenNewProductsViewModelAction.Tapped.NewProduct:
                        
                        self?.action.send(MyProductsViewModelAction.Tapped.NewProduct(productType: payload.productType))
                        
                    default: break
                    }
                    
                }.store(in: &bindings)
        }
    }
        
}

//MARK: - View

struct MyProductsOpenProductView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            Text(viewModel.title)
                .font(.textH3SB18240())
                .foregroundColor(.mainColorsBlack)
                
            LazyVGrid(columns: [GridItem(spacing: 12), GridItem()], spacing: 20) {
                    
                ForEach(viewModel.newProducts.items) { item in
                        
                    ButtonNewProduct(viewModel: item)
                        .frame(height: 124)
                }
            }
        }
        .padding([.horizontal], 20)
        .padding(.bottom, 74)
    }
}

//MARK: - Preview

struct MyProductsOpenProductView_Previews: PreviewProvider {

    static var previews: some View {
        
        MyProductsOpenProductView(viewModel: .previewSample)
            .previewLayout(.sizeThatFits) 
    }
}

//MARK: - Preview Content

extension MyProductsOpenProductView.ViewModel {

    static let previewSample = MyProductsOpenProductView
                                .ViewModel(newProducts: .init(items: [.sample,
                                                                      .sampleAccount,
                                                                      .sampleEmptySubtitle,
                                                                      .sampleLongSubtitle]))
}
