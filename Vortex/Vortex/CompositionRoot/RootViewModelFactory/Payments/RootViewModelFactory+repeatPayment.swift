//
//  RootViewModelFactory+repeatPayment.swift
//  Vortex
//
//  Created by Andryusina Nataly on 23.12.2024.
//

import Foundation
import RemoteServices
import GetInfoRepeatPaymentService

extension GetInfoRepeatPaymentDomain {
    
    struct PaymentPayload: Equatable {
        
        let operationID: OperationDetailID
        let activeProductID: ProductData.ID
        let operatorName: String
        let operatorIcon: String?
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func repeatPayment(
        payload: GetInfoRepeatPaymentDomain.PaymentPayload,
        closeAction: @escaping () -> Void,
        makeStandardFlow: @escaping (UtilityPaymentLastPayment,
        @escaping () -> Void,
        @escaping (PaymentsDomain.Navigation?) -> Void) -> Void,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        let infoPaymentService = nanoServiceComposer.compose(
            createRequest: RequestFactory.getInfoForRepeatPayment,
            mapResponse: RemoteServices.ResponseMapper.mapGetInfoRepeatPaymentResponse
        )

        infoPaymentService(.init(paymentOperationDetailId: payload.operationID)) { [weak self, infoPaymentService] in
            
            guard let self else { return completion(nil) }
            
            switch $0 {
            case let .success(info):
                
                let paymentFlow = info.paymentFlow(info.paymentFlow)
                
                switch paymentFlow {
                case .none:
                    guard let paymentsPayload = info.paymentsPayload(activeProductID: payload.activeProductID, getProduct: model.product(productId:))
                    else { return completion(nil) }
                    
                    return completion(getPaymentsNavigation(
                        from: paymentsPayload,
                        closeAction: closeAction
                    ))
                    
                case .mobile:
                    return completion(nil)
                    
                case .qr:
                    return completion(nil)
                    
                case .standard:
                    
                    let name = payload.operatorName
                    let md5Hash = payload.operatorIcon
                    
                    guard let utilityPaymentLastPayment = makeUtilityPaymentLastPayment(info, name: name, md5Hash: md5Hash)
                    else { return completion(nil) }
                    
                    makeStandardFlow(utilityPaymentLastPayment, closeAction, completion)
                    
                case .taxAndStateServices:
                    return completion(nil)
                    
                case .transport:
                    return completion(nil)
                }
                
            case .failure:
                completion(nil)
            }
            
            _ = infoPaymentService
        }
    }
    
    func makeUtilityPaymentLastPayment(
        _ info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        name: String,
        md5Hash: String?
    ) -> UtilityPaymentLastPayment? {
        
        guard let puref = info.parameterList.puref,
              let amount = info.parameterList.amount
        else { return nil }
        
        return .init(
            date: .now,
            amount: Decimal(amount),
            name: name,
            md5Hash: md5Hash,
            puref: puref,
            type: info.type.camelCased,
            additionalItems: info.parameterList.additional.map {
                
                .init(fieldName: $0.fieldname, fieldValue: $0.fieldvalue, fieldTitle: $0.fieldname, svgImage: nil)
            })
    }
}
