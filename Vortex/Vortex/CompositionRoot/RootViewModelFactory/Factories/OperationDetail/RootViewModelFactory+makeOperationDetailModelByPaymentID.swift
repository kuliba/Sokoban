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
        _ basicDetails: OperationDetailDomain.BasicDetails
    ) -> OperationDetailDomain.Model {
        
        return makeOperationDetailModel(
            basicDetails: basicDetails,
            load: getOperationDetailByPaymentID
        )
    }
    
    @inlinable
    func getOperationDetailByPaymentID(
        basicDetails: OperationDetailDomain.BasicDetails,
        completion: @escaping (Result<OperationDetailDomain.ExtendedDetails, Error>) -> Void
    ) {
        let load = onBackground(
            makeRequest: RequestFactory.createGetOperationDetailByPaymentIDRequestV3,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        )
        
        load(.init(basicDetails.paymentOperationDetailID)) {
            
            completion($0.map { $0.details(basicDetails: basicDetails) })
        }
    }
}

// MARK: - Adapters

private extension RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    func details(
        basicDetails: OperationDetailDomain.BasicDetails
    ) -> OperationDetailDomain.ExtendedDetails {
        
        return .init(
            product: basicDetails.product,
            status: basicDetails.status,
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
