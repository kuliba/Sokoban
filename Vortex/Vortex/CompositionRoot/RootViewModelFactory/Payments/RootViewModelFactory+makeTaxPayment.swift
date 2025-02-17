//
//  RootViewModelFactory+makeTaxPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeTaxPayment() -> ClosePaymentsViewModelWrapper {
        
        return .init(
            model: model,
            category: .taxes,
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func makeTaxPayment(
        c2gFlag: C2GFlag,
        closeAction: @escaping () -> Void
    ) -> CategoryPickerSectionDomain.Destination.Tax {
        
        let content = PaymentsViewModel(
            category: .taxes,
            model: model,
            closeAction: closeAction
        )
        let binder: TaxPaymentsDomain.Binder = composeBinder(
            content: content,
            getNavigation: getNavigation,
            witnesses: .empty
        )
        let cancellable = content.$content
            .compactMap(\.service)
            .first()
            .flatMap { $0.$content }
            .compactMap { $0.first as? PaymentsSelectServiceView.ViewModel }
            .sink {
                
                $0.items.append(.init(
                    id: UUID().uuidString,
                    icon: .ic24Contract,
                    title: "Поиск по УИН",
                    subTitle: "Поиск начислений по УИН",
                    service: .fns, // TODO: add new service?
                    action: { _ in binder.flow.event(.select(.searchByUIN)) }
                ))
            }
        
        switch c2gFlag.rawValue {
        case .active:
            return .v1(.init(model: binder, cancellable: cancellable))
            
        case .inactive:
            return .legacy(content)
        }
    }
    
    @inlinable
    func getNavigation(
        select: TaxPaymentsDomain.Select,
        notify: @escaping TaxPaymentsDomain.Notify,
        completion: (TaxPaymentsDomain.Navigation) -> Void
    ) {
        switch select {
        case .searchByUIN:
            completion(.searchByUIN)
        }
    }
    
    @inlinable
    func makeTaxPayment(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(
            category: .taxes,
            model: model,
            closeAction: closeAction
        )
    }
}

private extension PaymentsViewModel.ContentType {
    
    var service: PaymentsServiceViewModel? {
        
        guard case let .service(service) = self else { return nil }
        
        return service
    }
}
