//
//  RootViewModelFactory+makeCategoryPicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.01.2025.
//

import Combine
import PayHubUI

extension RootViewModelFactory {
    
    @inlinable
    func makeCategoryPicker(
    ) -> CategoryPickerViewDomain.Binder {
        
        let content = makeCategoryPickerContent(.init(
            loadCategories: getServiceCategoriesWithoutQR,
            reloadCategories: { $1(nil) },
            loadAllLatest: { $0(nil) }
        ))
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation(
                makeStandard: handleSelectedServiceCategory
            ),
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: CategoryPickerViewDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .failure:     return .milliseconds(100)
        case .destination: return settings.delay
        case .outside:     return .milliseconds(100)
        }
    }
    
    typealias MakeStandard = (ServiceCategory, @escaping (CategoryPickerViewDomain.Destination.Standard) -> Void) -> Void

    @inlinable
    func getNavigation(
        makeStandard: @escaping MakeStandard
    ) -> (
        CategoryPickerViewDomain.Select,
        @escaping CategoryPickerViewDomain.Notify,
        @escaping (CategoryPickerViewDomain.Navigation) -> Void
    ) -> Void {
        
        let composer = SelectedCategoryGetNavigationComposer(
            model: model,
            nanoServices: .init(
                makeMobile: makeMobilePayment,
                makeStandard: makeStandard,
                makeTax: makeTaxPayment,
                makeTransport: makeTransportPayment
            ),
            scheduler: schedulers.main
        )
        
        return { select, notify, completion in
            
            composer.getNavigation(select, notify) {
                
                completion($0)
                _ = composer
            }
        }
    }
}
