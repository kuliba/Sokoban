//
//  MainSectionOpenProductViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension MainSectionOpenProductView {

    class ViewModel: MainSectionCollapsableViewModel, ObservableObject {

        override var type: MainSectionType { .openProduct }
        @Published var newProducts: OpenNewProductsViewModel
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()

        init(newProducts: OpenNewProductsViewModel, model: Model = .emptyMock, isCollapsed: Bool) {
            
            self.newProducts = newProducts
            self.model = model
            super.init(isCollapsed: isCollapsed)
        }
        
        init(_ model: Model) {
            
            self.newProducts = .init(model)
            self.model = model
            super.init(isCollapsed: false)
            
            bind()
        }
        
        func bind() {
            
            newProducts.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    switch action {
                    case let payload as OpenNewProductsViewModelAction.Tapped.NewProduct:
                        
                        self?.action.send(MainSectionViewModelAction.OpenProduct.ButtonTapped(productType: payload.productType))
                        
                    default: break
                    }
                    
                }.store(in: &bindings)
        }
        
    }
}

//MARK: - View

struct MainSectionOpenProductView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {

                    ForEach($viewModel.newProducts.items) { $itemViewModel in

                        ButtonNewProduct(viewModel: itemViewModel)
                            .frame(width: 112, height: 124)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
//MARK: - Preview

struct MainBlockOpenProductsView_Previews: PreviewProvider {

    static var previews: some View {
        
        MainSectionOpenProductView(viewModel: .previewSample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionOpenProductView.ViewModel {

    static let previewSample = MainSectionOpenProductView.ViewModel(
        newProducts: .init(items: [.sample, .sample, .sample,.sample]),
        isCollapsed: false)

    static let sample = MainSectionOpenProductView.ViewModel(.emptyMock)
}
