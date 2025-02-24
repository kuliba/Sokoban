//
//  RootViewModelFactory+makeOperationDetailByPaymentID.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeOperationDetailByPaymentID(
        _ payload: OperationDetailDomain.ModelPayload
    ) -> OperationDetailDomain.Model {
        
        return makeOperationDetailModel(
            basicDetails: payload.basicDetails,
            load: { [weak self] completion in
                
                self?.getOperationDetailByPaymentID(payload, completion)
            }
        )
    }
    
    @inlinable
    func getOperationDetailByPaymentID(
        _ payload: OperationDetailDomain.ModelPayload,
        _ completion: @escaping (Result<OperationDetailDomain.ExtendedDetails, Error>) -> Void
    ) {
        let load = onBackground(
            makeRequest: RequestFactory.createGetOperationDetailByPaymentIDRequestV3,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        )
        
        load(.init(payload.paymentOperationDetailID)) {
            
            completion($0.map { $0.details(payload: payload) })
        }
    }
}

// MARK: - Adapters

extension OperationDetailDomain.ModelPayload {
    
    var basicDetails: OperationDetailDomain.BasicDetails {
        
        return .init(
            formattedAmount: formattedAmount,
            formattedDate: formattedDate,
            product: product
        )
    }
}

private extension RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    func details(
        payload: OperationDetailDomain.ModelPayload
    ) -> OperationDetailDomain.ExtendedDetails {
        
        return .init(
            product: payload.product,
            status: payload.status,
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
