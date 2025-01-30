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
        case .openProduct: return .milliseconds(100)
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
            print(openProductType)
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
}
