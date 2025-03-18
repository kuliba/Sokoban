//
//  MainSectionProductsViewComponent.swift
//  Vortex
//
//  Created by Max Gribov on 21.02.2022.
//

import Foundation
import SwiftUI
import Combine
import ScrollViewProxy
import Shimmer

//MARK: - ViewModel

extension MainSectionProductsView {
    
    class ViewModel: MainSectionCollapsableViewModel, ObservableObject {
        
        override var type: MainSectionType { .products }
        
        @Published private(set) var newProductButtonViewModel: NewProductButton.ViewModel?
        
        private let settings: MainProductsGroupSettings
        let productCarouselViewModel: ProductCarouselView.ViewModel
        
        var moreButton: MoreButtonViewModel {
            .init(
                icon: .ic24MoreHorizontal,
                action: { [weak self] in
                    
                    self?.action.send(
                        MainSectionViewModelAction.Products.MoreButtonTapped()
                    )
                }
            )
        }
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(
            isContentEmpty: Bool,
            settings: MainProductsGroupSettings = .base,
            productCarouselViewModel: ProductCarouselView.ViewModel,
            model: Model = .emptyMock,
            isCollapsed: Bool
        ) {
            
            self.settings = settings
            self.productCarouselViewModel = productCarouselViewModel
            self.model = model
            super.init(isCollapsed: isCollapsed)
        }
        
        convenience init(
            settings: MainProductsGroupSettings = .base,
            _ model: Model,
            promoProducts: [AdditionalProductViewModel]?
        ) {
            let carouselViewModel = ProductCarouselView.ViewModel(
                mode: .main,
                style: .regular,
                model: model,
                promoProducts: promoProducts
            )
            
            self.init(
                isContentEmpty: false,
                settings: settings,
                productCarouselViewModel: carouselViewModel,
                model: model,
                isCollapsed: false
            )
            
            bind()
        }
        
        private func bind() {

            typealias CarouselProductDidTapped = ProductCarouselViewModelAction.Products.ProductDidTapped
            typealias MainProductDidTapped = MainSectionViewModelAction.Products.ProductDidTapped
            
            productCarouselViewModel.action
                .compactMap { $0 as? CarouselProductDidTapped }
                .map(\.productId)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] id in
                    
                    self.action.send(MainProductDidTapped(productId: id))
                }
                .store(in: &bindings)

            typealias MainResetScroll = MainSectionViewModelAction.Products.ResetScroll
            typealias CarouselScrollToFirstGroup = ProductCarouselViewModelAction.Products.ScrollToFirstGroup

            action
                .compactMap { $0 as? MainResetScroll }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    self.productCarouselViewModel.action.send(CarouselScrollToFirstGroup())
                }
                .store(in: &bindings)
            
            typealias CarouselPromoDidTapped = ProductCarouselViewModelAction.Products.PromoDidTapped
            
            productCarouselViewModel.action
                .compactMap { $0 as? CarouselPromoDidTapped }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    
                    self?.action.send(MainSectionViewModelAction.Products.PromoDidTapped(promo: $0.promo))
                }
                .store(in: &bindings)
                        
            model.products
                .map { [unowned self] products in
                    
                    guard self.settings.isFreeCardAllowed(for: products)
                    else { return .none }
                    
                    return .some(.cardWanted(url: self.model.productsOpenAccountURL))
                }
                .receive(on: DispatchQueue.main)
                .assign(to: &$newProductButtonViewModel)
        }

        struct MoreButtonViewModel {
            
            let icon: Image
            let action: () -> Void
        }
    }
}

private extension NewProductButton.ViewModel {
    
    static func cardWanted(url: URL) -> NewProductButton.ViewModel {
        
        .init(
            openProductType: .card(.landing),
            subTitle: "Бесплатно",
            action: .url(url)
        )
    }
}

//MARK: - View

struct MainSectionProductsViewFactory {
    
    let makeProductCarouselView: (ProductCarouselView.ViewModel, @escaping () -> NewProductButton?) -> ProductCarouselView
}

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel
    let viewFactory: MainSectionProductsViewFactory
    
    var body: some View {
        
        CollapsableSectionView(
            title: viewModel.title,
            isShevronVisible: false,
            canCollapse: false,
            isCollapsed: .constant(false)
        ) {
            
            viewFactory.makeProductCarouselView(viewModel.productCarouselViewModel, newProductButton)
        }
        .overlay13(alignment: .top) {
            MoreButtonView(viewModel: viewModel.moreButton).padding(.trailing, 20)
        }
    }
}

//MARK: - Views

extension MainSectionProductsView {
    
    func newProductButton() -> NewProductButton? {
        
        viewModel.newProductButtonViewModel.map(NewProductButton.init(viewModel:))
    }
    
    struct MoreButtonView: View {
        
        let viewModel: ViewModel.MoreButtonViewModel
        
        var body: some View {
            
            HStack {
                
                Spacer()
                
                Button(action: viewModel.action) {
                    
                    ZStack {
                        
                        Circle()
                            .frame(width: 32, height: 32, alignment: .center)
                            .foregroundColor(.mainColorsGrayLightest)
                        
                        viewModel.icon
                            .renderingMode(.original)
                    }
                }
            }
            
        }
    }
}

//MARK: - Preview

struct MainSectionProductsView_Previews: PreviewProvider {
    
    private static func preview(_ viewModel: MainSectionProductsView.ViewModel) -> some View {
        MainSectionProductsView(viewModel: viewModel, viewFactory: .init(makeProductCarouselView: {_,_ in fatalError() }))
    }

    static var previews: some View {
        
        Group {
            
            preview(.sample)
            preview(.empty)
        }
        .previewLayout(.sizeThatFits)
    }
}

//MARK: - Preview Content

extension MainSectionProductsView.ViewModel {
    
    static let sample = MainSectionProductsView.ViewModel(
        isContentEmpty: false,
        productCarouselViewModel: .preview,
        isCollapsed: false
    )
    static let empty = MainSectionProductsView.ViewModel(
        isContentEmpty: true,
        productCarouselViewModel: .preview,
        isCollapsed: false
    )
}
