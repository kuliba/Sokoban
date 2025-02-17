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
        
        //  switch c2gFlag.rawValue {
        let model = PaymentsViewModel(
            category: .taxes,
            model: model,
            closeAction: closeAction
        )
        let cancellable = model.$content
            .handleEvents(receiveOutput: { print("#### model.$content", String(describing: $0)) })
            .compactMap(\.service)
            .first()
            .flatMap { $0.$content }
            .compactMap { $0.first as? PaymentsSelectServiceView.ViewModel }
            .sink {
                print("#### model.$content", String(describing: $0))
                
//                let viewModel = PaymentsSelectServiceView.ViewModel(items: [])
                $0.items.append(
                    .init(
                        id: UUID().uuidString,
                        icon: .ic24Contract,
                        title: "Поиск по УИН",
                        subTitle: "Поиск начислений по УИН",
                        service: .fns, // TODO: add new service?
                        action: { print("#### items.append", String(describing: $0)) }
                    )
                )
//                $0.objectWillChange.send()
            }
        return .init(model: model, cancellable: cancellable)
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
