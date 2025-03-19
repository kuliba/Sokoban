//
//  MainSectionOpenProductViewComponent.swift
//  Vortex
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
        private let makeButtons: OpenNewProductsViewModel.MakeNewProductButtons
        private var bindings = Set<AnyCancellable>()
        
        init(
            _ model: Model,
            makeButtons: @escaping OpenNewProductsViewModel.MakeNewProductButtons
        ) {
            self.makeButtons = makeButtons
            self.newProducts = .init(model, makeOpenNewProductButtons: makeButtons)
            self.model = model
            super.init(isCollapsed: false)
            
            bind()
        }
        
        func bind() {
            
            model.products
                .map(\.hasSavingsAccount)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    
                    guard let self else { return }
                    
                    newProducts = .init(model, makeOpenNewProductButtons: makeButtons)
                }.store(in: &bindings)

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
        
        CollapsableSectionView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.newProducts.items, id: \.type) { itemViewModel in
                        
                        NewProductButton(viewModel: itemViewModel)
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
    
    static let previewSample = MainSectionOpenProductView.ViewModel(.emptyMock) { _ in
        
        [.sample, .sample, .sample,.sample]
    }
    
    static let sample = MainSectionOpenProductView.ViewModel(.emptyMock) { _ in [] }
}
