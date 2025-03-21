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
        
        @Published var newProducts: Node<OpenNewProductsViewModel>
        
        private let model: Model
        private let makeButtons: OpenNewProductsViewModel.MakeNewProductButtons
        private var bindings = Set<AnyCancellable>()
        
        init(
            _ model: Model,
            makeButtons: @escaping OpenNewProductsViewModel.MakeNewProductButtons
        ) {
            self.makeButtons = makeButtons
            self.model = model
            let buttons: OpenNewProductsViewModel = .init(model, makeOpenNewProductButtons: makeButtons)
            self.newProducts = .init(model: buttons, cancellables: [])
            super.init(isCollapsed: false)
            
            self.newProducts = bindButtons(buttons)

            bind()
        }
        
        func bind() {
            
            model.products
                .map(\.hasSavingsAccount)
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in self?.updateButtons() }
                .store(in: &bindings)
        }
        
        func bindButtons(_ buttons: OpenNewProductsViewModel) -> Node<OpenNewProductsViewModel> {
            
            let cancellable = buttons.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    switch action {
                    case let payload as OpenNewProductsViewModelAction.Tapped.NewProduct:
                        
                        self?.action.send(MainSectionViewModelAction.OpenProduct.ButtonTapped(productType: payload.productType))
                        
                    default: break
                    }
                }
            
            return .init(model: buttons, cancellable: cancellable)
        }

        private func updateButtons() {
            
            let buttons: OpenNewProductsViewModel = .init(model, makeOpenNewProductButtons: makeButtons)
            newProducts = bindButtons(buttons)
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
                    
                    ForEach(viewModel.newProducts.model.items, id: \.type) { itemViewModel in
                        
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
