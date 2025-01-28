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
            getNavigation: getNavigation,
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
        select category: CategoryPickerViewDomain.Select,
        notify: @escaping CategoryPickerViewDomain.Notify,
        completion: @escaping (CategoryPickerViewDomain.Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.destination(.mobile(makeMobilePayment())))
            
        case .qr:
            completion(.outside(.qr))
            
        case .standard:
            handleSelectedServiceCategory(category) {
                
                completion(.destination(.standard($0)))
            }
            
        case .taxAndStateServices:
            completion(.destination(.taxAndStateServices(makeTaxPayment())))
            
        case .transport:
            guard let transport = makeTransportPayment()
            else { return completion(.failure(.transport)) }
            
            completion(.destination(.transport(transport)))
        }
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
