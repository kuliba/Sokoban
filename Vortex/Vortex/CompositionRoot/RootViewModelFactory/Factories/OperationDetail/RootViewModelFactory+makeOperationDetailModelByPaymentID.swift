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
        basicDetails: OperationDetailDomain.BasicDetails
    ) -> OperationDetailDomain.Model {
        
        return makeOperationDetailModel(
            initialState: .init(
                basicDetails: basicDetails,
                extendedDetails: .pending
            ),
            load: getOperationDetailByPaymentID
        )
    }
    
    @inlinable
    func getOperationDetailByPaymentID(
        payload: OperationDetailDomain.EnhancedPayload,
        completion: @escaping (Result<OperationDetailDomain.ExtendedDetails, Error>) -> Void
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
        product: OperationDetailDomain.Product,
        status: OperationDetailDomain.Status
    ) -> OperationDetailDomain.ExtendedDetails {
        
        return .init(
            product: product,
            status: status,
            comment: comment,
            dateForDetail: dateForDetail,
            dateN: dateN,
            discount: discount,
            discountExpiry: discountExpiry,
            formattedAmount: formattedAmount,
            legalAct: legalAct,
            payeeFullName: payeeFullName,
            paymentTerm: paymentTerm,
            realPayerFIO: realPayerFIO,
            realPayerINN: realPayerINN,
            realPayerKPP: realPayerKPP,
            supplierBillID: supplierBillID,
            transAmm: formattedAmount,
            transferNumber: transferNumber,
            upno: upno
        )
    }
}
