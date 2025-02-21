//
//  RootViewModelFactory+makeOperationDetailModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RemoteServices
import RxViewModel
import ProductSelectComponent

extension RootViewModelFactory {
    
    @inlinable
    func makeOperationDetailModel(
        initialState: OperationDetailDomain.State
    ) -> OperationDetailDomain.Model {
        
        return makeOperationDetailModel(
            initialState: initialState,
            load: getOperationDetailByPaymentID
        )
    }
    
    typealias LoadOperationDetailCompletion = (Result<OperationDetailDomain.State.Details, Error>) -> Void
    typealias LoadOperationDetail = (OperationDetailDomain.EnhancedPayload, @escaping LoadOperationDetailCompletion) -> Void
    
    @inlinable
    func makeOperationDetailModel(
        initialState: OperationDetailDomain.State,
        load: @escaping LoadOperationDetail
    ) -> OperationDetailDomain.Model {
        
        let reducer = OperationDetailDomain.Reducer()
        let effectHandler = OperationDetailDomain.EffectHandler { completion in
            
            load(initialState.payload, completion)
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
    
    @inlinable
    func getOperationDetailByPaymentID(
        payload: OperationDetailDomain.EnhancedPayload,
        completion: @escaping (Result<OperationDetailDomain.State.Details, Error>) -> Void
    ) {
        let load = onBackground(
            makeRequest: RequestFactory.createGetOperationDetailByPaymentIDRequestV3,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        )
        
        load(.init(payload.paymentOperationDetailID)) {
            
            completion($0.map { $0.details(
                formattedAmount: payload.formattedAmount,
                product: payload.product,
                status: payload.status
            )})
        }
    }
}

// MARK: - Adapters

private extension RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
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

private extension OperationDetailDomain.State {
    
    var payload: OperationDetailDomain.EnhancedPayload {
        
        return .init(
            formattedAmount: response.formattedAmount,
            paymentOperationDetailID: response.paymentOperationDetailID,
            product: response.product,
            status: response.status
        )
    }
}

extension OperationDetailDomain {
    
    struct EnhancedPayload: Equatable {
        
        let formattedAmount: String?
        let paymentOperationDetailID: Int
        let product: ProductSelect.Product
        let status: OperationDetailDomain.State.Status
    }
}
