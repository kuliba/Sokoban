//
//  RootViewModelFactory+repeatPayment.swift
//  Vortex
//
//  Created by Andryusina Nataly on 23.12.2024.
//

import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func repeatPayment(
        operationID: OperationDetailID,
        activeProductID: ProductData.ID,
        closeAction: @escaping () -> Void,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        let infoPaymentService = nanoServiceComposer.compose(
            createRequest: RequestFactory.getInfoForRepeatPayment,
            mapResponse: RemoteServices.ResponseMapper.mapGetInfoRepeatPaymentResponse
        )

        infoPaymentService(.init(paymentOperationDetailId: operationID)) { [weak self, infoPaymentService] in
            
            guard let self else { return completion(nil) }
            
            switch $0 {
            case let .success(info):
                let navigation = getInfoRepeatPaymentNavigation(
                    from: info,
                    activeProductID: activeProductID,
                    getProduct: { [weak model] in model?.product(productId: $0) },
                    closeAction: closeAction
                )
                completion(navigation)
                
            case .failure:
                completion(nil)
            }
            
            _ = infoPaymentService
        }
    }
}
