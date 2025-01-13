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
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        repeatPayment(
            payload: payload,
            closeAction: closeAction,
            makeStandardFlow: processPayments,
            completion: completion
        )
    }
    
    func processPayments(
        repeatPayment: RepeatPayment,
        close: @escaping () -> Void,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        processPayments(
            repeatPayment: repeatPayment,
            notify: { _ in close() },
            completion: completion
        )
    }
    
    typealias MakeStandardFlow = (UtilityPaymentLastPayment, @escaping () -> Void, @escaping (PaymentsDomain.Navigation?) -> Void) -> Void
    
    @inlinable
    func repeatPayment(
        payload: GetInfoRepeatPaymentDomain.PaymentPayload,
        closeAction: @escaping () -> Void,
        makeStandardFlow: @escaping MakeStandardFlow,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        let infoPaymentService = nanoServiceComposer.compose(
            createRequest: RequestFactory.getInfoForRepeatPayment,
            mapResponse: RemoteServices.ResponseMapper.mapGetInfoRepeatPaymentResponse
        )
        
        infoPaymentService(
            .init(paymentOperationDetailId: payload.operationID)
        ) { [weak self, infoPaymentService] in
            
            guard let self else { return completion(nil) }
            
            switch $0 {
            case let .success(info):
                
                let paymentFlow = info.paymentFlow(info.paymentFlow)
                
                switch paymentFlow {
                case .qr:
                    return completion(nil)
                    
                case .standard:
                    guard let utilityPaymentLastPayment = makeRepeatPayment(
                        info,
                        name: payload.operatorName,
                        md5Hash: payload.operatorIcon
                    )
                    else { return completion(nil) }
                    
                    makeStandardFlow(utilityPaymentLastPayment, closeAction, completion)
                    
                default: // .none,  .mobile, .taxAndStateServices, .transport

                    guard let paymentsPayload = info.paymentsPayload(activeProductID: payload.activeProductID, getProduct: model.product(productId:))
                    else { return completion(nil) }
                    
                    return completion(getPaymentsNavigation(
                        from: paymentsPayload,
                        closeAction: closeAction
                    ))
                }
                
            case .failure:
                completion(nil)
            }
            
            _ = infoPaymentService
        }
    }
    
    func makeRepeatPayment(
        _ info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        name: String,
        md5Hash: String?
    ) -> RepeatPayment? {
        
        guard let puref = info.parameterList.puref else { return nil }
        
        return .init(
            date: .now,
            amount: Decimal(info.parameterList.amount ?? 0),
            name: name,
            md5Hash: md5Hash,
            puref: puref,
            type: info.type.camelCased,
            additionalItems: info.parameterList.additional.map {
                
                .init(fieldName: $0.fieldname, fieldValue: $0.fieldvalue, fieldTitle: $0.fieldname, svgImage: nil)
            })
    }
}
