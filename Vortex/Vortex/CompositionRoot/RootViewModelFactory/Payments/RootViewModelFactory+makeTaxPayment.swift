//
//  RootViewModelFactory+makeTaxPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

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
            .handleEvents(receiveOutput: { print("#### model.$content", $0) })
            .compactMap(\.service)
            .first()
            .sink {
                print("#### model.$content switched to PaymentsServiceViewModel", $0)
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
