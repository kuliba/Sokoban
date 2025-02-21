//
//  RootViewModelFactory+makeOperationDetailModelByPaymentID.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeOperationDetailModelByPaymentID(
        response: OperationDetailDomain.State.EnhancedResponse
    ) -> OperationDetailDomain.Model {
        
        return makeOperationDetailModel(
            initialState: .init(
                details: .pending,
                response: response
            ),
            load: getOperationDetailByPaymentID
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
