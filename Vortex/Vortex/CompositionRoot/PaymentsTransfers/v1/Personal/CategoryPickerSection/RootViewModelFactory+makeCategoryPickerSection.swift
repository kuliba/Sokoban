//
//  RootViewModelFactory+makeCategoryPickerSection.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.10.2024.
//

import Combine
import PayHubUI

protocol ReloadableCategoryPicker: CategoryPicker {
    
    func reload()
}

extension CategoryPickerSectionDomain.Binder: ReloadableCategoryPicker {
    
    func reload() {
        
        content.event(.reload)
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func makeCategoryPickerSection(
        c2gFlag: C2GFlag
    ) -> CategoryPickerSectionDomain.Binder {
        
        let nanoServices = composePaymentsTransfersPersonalNanoServices()
        
        return makeCategoryPickerSection(
            c2gFlag: c2gFlag,
            nanoServices: nanoServices
        )
    }
    
    @inlinable
    func makeCategoryPickerSection(
        c2gFlag: C2GFlag,
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> CategoryPickerSectionDomain.Binder {
        
        let content = makeCategoryPickerContent(nanoServices: nanoServices)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: { [weak self] select, notify, completion in
                
                self?.getNavigation(
                    c2gFlag: c2gFlag,
                    select: select,
                    notify: notify,
                    completion: completion
                )
            },
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: CategoryPickerSectionDomain.Navigation
    ) -> Delay {
        
        return .zero
    }
    
    @inlinable
    func getNavigation(
        c2gFlag: C2GFlag,
        select: CategoryPickerSectionDomain.Select,
        notify: @escaping CategoryPickerSectionDomain.Notify,
        completion: @escaping (CategoryPickerSectionDomain.Navigation) -> Void
    ) {
        switch select {
        case let .category(category):
            getNavigation(c2gFlag: c2gFlag, category: category, notify: notify, completion: completion)
            
        case .qr:
            completion(.outside(.qr))
        }
    }
    
    // TODO: repeating code as in RootViewModelFactory+makeCategoryPicker.swift:64
    @inlinable
    func getNavigation(
        c2gFlag: C2GFlag,
        category: ServiceCategory,
        notify: @escaping CategoryPickerSectionDomain.Notify,
        completion: @escaping (CategoryPickerSectionDomain.Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.destination(.mobile(makeMobilePayment(
                closeAction: { notify(.dismiss) }
            ))))
            
        case .qr:
            completion(.outside(.qr))
            
        case .standard:
            completion(.outside(.standard(category)))
            
        case .taxAndStateServices:
            completion(.destination(.taxAndStateServices(makeTaxPayment(
                c2gFlag: c2gFlag,
                closeAction: { notify(.dismiss) }
            ))))
            
        case .transport:
            guard let transport = makeTransportPayment()
            else { return completion(.failure(.transport)) }
            
            completion(.destination(.transport(transport)))
            
        case .uin:
            completion(.outside(.searchByUIN))
            
        default:
            completion(.failure(.init(id: .init(), message: "Обновите приложение до последней версии, чтобы получить доступ к новому разделу.")))
        }
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}

private extension String {
    
    static let qr = "QR"
    static let standard = "STANDARD_FLOW"
    static let taxAndStateServices = "TAX_AND_STATE_SERVICE"
    static let uin = "UIN"
}
