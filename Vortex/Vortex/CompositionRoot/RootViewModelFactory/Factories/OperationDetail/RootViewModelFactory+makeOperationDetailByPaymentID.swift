//
//  RootViewModelFactory+makeOperationDetailByPaymentID.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import Foundation
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
        
        load(.init(payload.paymentOperationDetailID)) { [weak self] in
            
            guard let self else { return }
            
            let format = self.format(amount:currency:)
            
            completion($0.map { $0.details(payload: payload, format: format) })
        }
    }
}

// MARK: - Adapters

extension OperationDetailDomain.ModelPayload {
    
    var basicDetails: OperationDetailDomain.BasicDetails {
        
        return .init(
            formattedAmount: formattedAmount,
            formattedDate: dateForDetail,
            product: product
        )
    }
}

private extension RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    func details(
        payload: OperationDetailDomain.ModelPayload,
        format: @escaping (Decimal?, String?) -> String?
    ) -> OperationDetailDomain.ExtendedDetails {
        
        return .init(
            product: payload.product,
            status: payload.status,
            comment: comment,
            dateForDetail: dateForDetail,
            dateN: dateN,
            discount: discount,
            discountExpiry: discountExpiry,
            formattedAmount: format(payerAmount, payerCurrency),
            legalAct: legalAct,
            payeeFullName: payeeFullName,
            paymentTerm: paymentTerm,
            realPayerFIO: realPayerFIO,
            realPayerINN: realPayerINN,
            realPayerKPP: realPayerKPP,
            supplierBillID: supplierBillID,
            transAmm: format(transAmm, payerCurrency),
            transferNumber: transferNumber,
            upno: upno
        )
    }
}
