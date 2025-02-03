//
//  RootViewModelFactory+makeOpenProductFlow.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeOpenProductFlow(
        featureFlags: FeatureFlags
    ) -> OpenProductDomain.Flow {
        
        // TODO: extract flow composer
        let binder: Binder<Void, OpenProductDomain.Flow> = composeBinder(
            content: (),
            delayProvider: delayProvider,
            getNavigation: { [weak self] select, notify, completion in
                
                self?.getNavigation(
                    featureFlags: featureFlags,
                    select: select,
                    notify: notify,
                    completion: completion
                )
            },
            witnesses: .empty
        )
        
        return binder.flow
    }
    
    @inlinable
    func delayProvider(
        navigation: OpenProductDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .alert:       return .milliseconds(100)
        case .openAccount: return .milliseconds(100)
        case .openCard:    return .milliseconds(100)
        case .openDeposit: return .milliseconds(100)
        case .openProduct: return .milliseconds(100)
        case .openURL:     return .milliseconds(100)
        }
    }
    
    @inlinable
    func getNavigation(
        featureFlags: FeatureFlags,
        select: OpenProductDomain.Select,
        notify: @escaping OpenProductDomain.Notify,
        completion: @escaping (OpenProductDomain.Navigation) -> Void
    ) {
        switch select {
        case .openProduct:
            completion(.openProduct(makeOpenProductNode(
                featureFlags: featureFlags,
                notify: { notify(.select(.productType($0))) }
            )))
            
        case let .productType(openProductType):
            getNavigation(openProductType: openProductType, notify: notify, completion: completion)
        }
    }
    
    @inlinable
    func getNavigation(
        openProductType: OpenProductType,
        notify: @escaping OpenProductDomain.Notify,
        completion: @escaping (OpenProductDomain.Navigation) -> Void
    ) {
        switch openProductType {
        case .account:
            completion(makeOpenAccountModel().map { .openAccount($0) } ?? .alert("Ошибка открытия счета."))
            
        case .card:
            switch openCard(dismiss: { notify(.dismiss) }) {
            case let .first(openCard):
                completion(.openCard(openCard))
                
            case let .second(url):
                completion(.openURL(url))
            }
            
        case .deposit:
            completion(.openDeposit(openDeposit(dismiss: { notify(.dismiss) })))
            
        case .insurance:
            break // TODO: fixme
            
        case .loan:
            break // TODO: fixme - add openCollateralLoanLanding
            
        case .mortgage:
            break // TODO: fixme
            
        case .savingsAccount:
            break // TODO: fixme
            
        case .sticker:
            break // TODO: fixme
        }
    }
    
    @inlinable
    func makeOpenProductNode(
        featureFlags: FeatureFlags,
        notify: @escaping (OpenProductType) -> Void
    ) -> Node<MyProductsOpenProductView.ViewModel> {
        
        let viewModel = MyProductsOpenProductView.ViewModel(model) { [weak self] in
            
            guard let self else { return [] }
            
            return makeOpenNewProductButtons(
                collateralLoanLandingFlag: featureFlags.collateralLoanLandingFlag,
                savingsAccountFlag: featureFlags.savingsAccountFlag,
                action: $0
            )
        }
        
        return .init(
            model: viewModel,
            cancellable: viewModel.action
                .compactMap { $0 as? MyProductsViewModelAction.Tapped.NewProduct }
                .map(\.productType)
                .sink { notify($0) }
        )
    }
    
    @inlinable
    func makeOpenAccountModel() -> OpenAccountViewModel? {
        
        let accountProductsList = model.accountProductsList.value
        
        guard let viewModel = OpenAccountViewModel(model, products: accountProductsList)
        else { return nil }
        
        return viewModel
    }
    
    @inlinable
    func openCard(
        dismiss: @escaping () -> Void
    ) -> Either<AuthProductsViewModel, URL> {
        
        if model.onlyCorporateCards {
            
            return .second(model.productsOpenAccountURL)
            
        } else {
            
            let authProductsViewModel = AuthProductsViewModel(
                model,
                products: model.catalogProducts.value,
                dismissAction: dismiss
            )
            
            return .first(authProductsViewModel)
        }
    }
    
    @inlinable
    func openDeposit(
        dismiss: @escaping () -> Void
    ) -> OpenDepositListViewModel {
        
        let openDepositViewModel = OpenDepositListViewModel(
            model,
            catalogType: .deposit,
            dismissAction: dismiss,
            makeAlertViewModel: { .disableForCorporateCard(primaryAction: $0) }
        )
        
        return openDepositViewModel
    }
}

enum Either<First, Second> {
    
    case first(First)
    case second(Second)
}

extension Either: Equatable where First: Equatable, Second: Equatable {}
