//
//  ViewComponents+payments.swift
//  Vortex
//
//  Created by Igor Malyarov on 17.02.2025.
//

extension ViewComponents {
    
    func makePaymentsView(
        _ viewModel: PaymentsViewModel,
        isRounded: Bool = false
    ) -> PaymentsView {
        
        return .init(
            viewModel: viewModel,
            viewFactory: makePaymentsViewFactory(isRounded: isRounded)
        )
    }
    
    func makePaymentsViewFactory(
        isRounded: Bool
    ) -> PaymentsViewFactory {
        
        return .init(
            makePaymentsOperationView: makePaymentsOperationView,
            makePaymentsServiceView: {
                
                makePaymentsServiceView($0, isRounded: isRounded)
            },
            makePaymentsSuccessView: makePaymentsSuccessView
        )
    }
    
    func makePaymentsServiceView(
        _ viewModel: PaymentsServiceViewModel,
        isRounded: Bool
    ) -> PaymentsServiceView {
        
        return .init(
            viewModel: viewModel,
            isRounded: isRounded,
            viewFactory: makePaymentsServiceViewFactory()
        )
    }
    
    func makePaymentsServiceViewFactory(
    ) -> PaymentsServiceViewFactory {
        
        return .init(makePaymentsOperationView: makePaymentsOperationView)
    }
    
    func makePaymentsOperationView(
        _ viewModel: PaymentsOperationViewModel
    ) -> PaymentsOperationView {
        
        return .init(
            viewModel: viewModel,
            viewFactory: makePaymentsOperationViewFactory()
        )
    }
    
    func makePaymentsOperationViewFactory(
    ) -> PaymentsOperationViewFactory {
        
        return .init(
            makeContactsView: makeContactsView,
            makePaymentsSuccessView: makePaymentsSuccessView,
            makeProductSelectorView: makeProductSelectorView)
    }
    
    func makeProductSelectorView(
        _ viewModel: ProductSelectorView.ViewModel
    ) -> ProductSelectorView {
        
        return .init(
            viewModel: viewModel,
            viewFactory: makeProductSelectorViewFactory()
        )
    }
    
    func makeProductSelectorViewFactory(
    ) -> ProductSelectorViewFactory {
        
        return .init(makeProductCarouselView: makeProductCarouselView)
    }
    
    func makeProductCarouselView(
        viewModel: ProductCarouselView.ViewModel,
        newProductButton: @escaping () -> NewProductButton?
    ) -> ProductCarouselView {
        
        return .init(
            viewModel: viewModel,
            newProductButton: newProductButton,
            viewFactory: makeProductCarouselViewFactory()
        )
    }
    
    func makeProductCarouselViewFactory(
    ) -> ProductCarouselViewFactory {
        
        return .init(
            makeOptionSelectorView: makeOptionSelectorView,
            makePromoView: makePromoView
        )
    }
    
    func makeOptionSelectorView(
        viewModel: OptionSelectorView.ViewModel
    ) -> OptionSelectorView {
        
        return .init(
            viewModel: viewModel,
            viewFactory: makeOptionSelectorViewFactory()
        )
    }
    
    func makeOptionSelectorViewFactory() -> OptionSelectorViewFactory {
        
        return .init(makeOptionButtonView: makeOptionButtonView)
    }
    
    func makePromoView(
        _ viewModel: AdditionalProductViewModel
    ) -> AdditionalProductView {
        
        return .init(viewModel: viewModel, makeIconView: makeIconView)
    }
    
    func makeOptionButtonView(
        viewModel: OptionSelectorView.ViewModel.OptionViewModel,
        isSelected: Bool
    ) -> OptionSelectorView.OptionButtonView {
        
        return .init(
            viewModel: viewModel,
            isSelected: isSelected,
            viewFactory: makeOptionButtonViewFactory()
        )
    }
    
    func makeOptionButtonViewFactory(
    ) -> OptionSelectorView.OptionButtonViewFactory {
        
        return .init(makeProductsCategoryView: makeCategoryView)
    }
}
