//
//  RootViewModelFactory+makeOperationDetail.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.02.2025.
//

import Foundation
import GetOperationDetailService
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeOperationDetail(
        digest: OperationDetailDomain.StatementDigest
    ) -> OperationDetailDomain.Model {
        
        return makeOperationDetailModel(
            basicDetails: digest.basicDetails,
            load: { [weak self] completion in
                
                self?.getOperationDetail(digest, completion)
            }
        )
    }

    @inlinable
    func getOperationDetail(
        _ digest: OperationDetailDomain.StatementDigest,
        _ completion: @escaping (Result<OperationDetailDomain.ExtendedDetails, Error>) -> Void
    ) {
        let load = onBackground(
            makeRequest: RequestFactory.createGetOperationDetailRequestV3,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailResponse
        )
        
        load(digest.documentID) { [weak self] in
            
            guard let self else { return }
            
            completion($0.result(digest: digest, format: format(amount:currency:)))
        }
    }
    
    @inlinable
    func format(amount: Decimal?, currency: String?) -> String? {
        
        format(amount: amount, currencyCode: currency, style: .normal)
    }
}

// MARK: - Adapters

extension OperationDetailDomain.StatementDigest {
    
    var basicDetails: OperationDetailDomain.BasicDetails {
        
        return .init(
            formattedAmount: formattedAmount,
            formattedDate: formattedDate,
            product: product
        )
    }
}

private extension Result
where Success == RemoteServices.ResponseMapper.GetOperationDetailResponse {
    
    func result(
        digest: OperationDetailDomain.StatementDigest,
        format: @escaping (Decimal?, String?) -> String?
    ) -> Result<OperationDetailDomain.ExtendedDetails, Error> {
        
        guard let result = try? get(),
              let status = result.status
        else { return .failure(GetOperationDetailFailure.unknownStatus) }
        
        return .success(result.details(
            digest: digest,
            format: format,
            status: status
        ))
    }
    
    enum GetOperationDetailFailure: Error {
        
        case unknownStatus
    }
}

private extension RemoteServices.ResponseMapper.GetOperationDetailResponse {
    
    func details(
        digest: OperationDetailDomain.StatementDigest,
        format: @escaping (Decimal?, String?) -> String?,
        status: OperationDetailDomain.Status
    ) -> OperationDetailDomain.ExtendedDetails {
        
        return .init(
            product: digest.product,
            status: status,
            comment: comment,
            dateForDetail: dateForDetail,
            dateN: dateN,
            discount: discount,
            discountExpiry: discountExpiry,
            formattedAmount: format(amount, payerCurrency),
            legalAct: legalAct,
            payeeFullName: payeeFullName,
            paymentTerm: paymentTerm,
            realPayerFIO: realPayerFIO,
            realPayerINN: realPayerINN,
            realPayerKPP: realPayerKPP,
            supplierBillID: supplierBillID,
            transAmm: format(transAmm, payerCurrency),
            transferNumber: transferNumber,
            upno: UPNO
        )
    }
    
    var status: OperationDetailDomain.Status? {
        
        switch operationStatus {
        case "COMPLETE":    return .completed
        case "IN_PROGRESS": return .inflight
        case "REJECTED":    return .rejected
        default:            return nil
        }
    }
}
