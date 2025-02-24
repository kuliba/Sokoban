//
//  RootViewModelFactory+makeOperationDetailModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RemoteServices
import RxViewModel

extension RootViewModelFactory {
    
    @inlinable
    func makeOperationDetailModel(
        initialState: OperationDetailDomain.State
    ) -> OperationDetailDomain.Model {
        
        let load = onBackground(
            makeRequest: RequestFactory.createGetOperationDetailByPaymentIDRequestV3,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        )
        
        let reducer = OperationDetailDomain.Reducer()
        let effectHandler = OperationDetailDomain.EffectHandler { completion in
            
            load(.init(initialState.response.paymentOperationDetailID)) {
                
                completion($0.map { $0.details(
                    formattedAmount: initialState.response.formattedAmount,
                    product: initialState.response.product,
                    status: initialState.response.status
                )})
            }
        }
        
        return .init(
            initialState: initialState,
            reduce: { state, event in
                
                var state = state
                let (details, effect) = reducer.reduce(state.details, event)
                state.details = details
                
                return (state, effect)
            },
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }
}

extension RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    func details(
        formattedAmount: String?,
        product: OperationDetailDomain.State.Product,
        status: OperationDetailDomain.State.Status
    ) -> OperationDetailDomain.State.Details {
        
        return .init(
            product: product,
            status: status,
            dateForDetail: dateForDetail,
            realPayerFIO: realPayerFIO,
            payeeFullName: payeeFullName,
            supplierBillID: supplierBillID,
            comment: comment,
            realPayerINN: realPayerINN,
            realPayerKPP: realPayerKPP,
            dateN: dateN,
            paymentTerm: paymentTerm,
            legalAct: legalAct,
            transAmm: formattedAmount,
            discount: discount,
            discountExpiry: discountExpiry,
            formattedAmount: formattedAmount,
            upno: upno,
            transferNumber: transferNumber
        )
    }
}
