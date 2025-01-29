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
            witnesses: .init(
                emitting: { _ in Empty() },
                dismissing: { _ in {} }
            )
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
        select: CategoryPickerViewDomain.Select,
        notify: @escaping CategoryPickerViewDomain.Notify,
        completion: @escaping (CategoryPickerViewDomain.Navigation) -> Void
    ) {
        switch select {
        case let .category(category):
            getNavigation(category: category, notify: notify, completion: completion)
            
        case let .outside(outside):
            completion(.outside(outside))
        }
    }
    
    @inlinable
    func getNavigation(
        category: ServiceCategory,
        notify: @escaping CategoryPickerViewDomain.Notify,
        completion: @escaping (CategoryPickerViewDomain.Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.destination(.mobile(makeMobilePayment(
                closeAction: { notify(.dismiss) }
            ))))
            
        case .qr:
            completion(.outside(.qr))
            
        case .standard:
            handleSelectedServiceCategory(category) { [weak self] in
                
                guard let self else { return }
                
                completion(.destination(.standard(.init(
                    model: $0,
                    cancellable: bind(standard: $0, to: notify)
                ))))
            }
            
        case .taxAndStateServices:
            completion(.destination(.taxAndStateServices(makeTaxPayment())))
            
        case .transport:
            guard let transport = makeTransportPayment()
            else { return completion(.failure(.transport)) }
            
            completion(.destination(.transport(transport)))
        }
    }
    
    @inlinable
    func bind(
        standard: StandardSelectedCategoryDestination,
        to notify: @escaping CategoryPickerViewDomain.Notify
    ) -> AnyCancellable {
        
        switch standard {
        case let .failure(failure):
            return failure.flow.$state.compactMap(\.outside)
                .sink { notify(.select(.outside($0))) }
            
        case let .success(success):
            return success.flow.$state.compactMap(\.outside)
                .sink { notify(.select(.outside($0))) }
        }
    }
}

private extension ServiceCategoryFailureDomain.FlowDomain.State {
    
    var outside: CategoryPickerViewDomain.Outside? {
        
        switch navigation {
        case .none:          return nil
        case .detailPayment: return nil
        case .scanQR:        return .qr
        }
    }
}

private extension PaymentProviderPickerDomain.FlowDomain.State {
    
    var outside: CategoryPickerViewDomain.Outside? {
        
        switch navigation {
        case .none, .alert, .destination:
            return nil
            
        case let .outside(outside):
            switch outside {
            case .back:     return nil
            case .chat:     return .chat
            case .main:     return .main
            case .payments: return .payments
            case .qr:       return .qr
            }
        }
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
