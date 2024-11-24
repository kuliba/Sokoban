//
//  RootViewModelFactory+makePaymentsNode.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.11.2024.
//

extension RootViewModelFactory {
    
    func makePaymentsNode(
        payload: ClosePaymentsViewModelWrapper.Payload,
        notifyClose: @escaping () -> Void
    ) -> Node<ClosePaymentsViewModelWrapper> {
        
        let wrapper = ClosePaymentsViewModelWrapper(
            payload: payload,
            model: model,
            scheduler: schedulers.main
        )
        
        return .init(
            model: wrapper,
            cancellable: wrapper.$isClosed.sink { _ in notifyClose() }
        )
    }
}
