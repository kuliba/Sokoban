//
//  ResponseMapper+mapMakeTransferResponse.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapMakeTransferResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<MakeTransferResponse> {
        
        map(data, httpURLResponse, mapOrThrow: MakeTransferResponse.init)
    }
}

extension ResponseMapper {
    
    public struct MakeTransferResponse: Equatable {
        
        public let operationDetailID: Int
        public let documentStatus: DocumentStatus
        
        public init(
            operationDetailID: Int,
            documentStatus: DocumentStatus
        ) {
            self.operationDetailID = operationDetailID
            self.documentStatus = documentStatus
        }
    }
}

public extension ResponseMapper.MakeTransferResponse {
    
    enum DocumentStatus {
        
        case complete, inProgress, rejected
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let paymentOperationDetailId : Int
        let documentStatus: _DocumentStatus
    }
}

private extension ResponseMapper._Data {
    
    enum _DocumentStatus: String, Decodable {
        
        // complete
        case complete = "COMPLETE"
        case success = "SUCCESS"
        case accepted = "Accepted"
        // in progress
        case inProgress = "IN_PROGRESS"
        case pending = "PENDING"
        case timeout = "TIMEOUT"
        case executed = "Executed"
        case postponed = "Postponed"
        case recall = "Recall"
        // rejected
        case failure = "FAILURE"
        case cancelled = "CANCELLED"
        case rejectedCap = "REJECTED"
        case notFound = "NOT_FOUND"
        case undefined = "UNDEFINED"
        case rejected = "Rejected"
    }
}

// MARK: - Adapters

private extension ResponseMapper.MakeTransferResponse {
    
    init(_ data: ResponseMapper._Data) {
        
        self.init(
            operationDetailID: data.paymentOperationDetailId,
            documentStatus: .init(data.documentStatus)
        )
    }
}

private extension ResponseMapper.MakeTransferResponse.DocumentStatus {
    
    init(_ documentStatus: ResponseMapper._Data._DocumentStatus) {
        
        switch documentStatus {
        case .complete, .success, .accepted:
            self = .complete
            
        case .inProgress, .pending, .timeout, .executed, .postponed, .recall:
            self = .inProgress
            
        case .rejected, .failure, .cancelled, .rejectedCap, .notFound, .undefined:
            self = .rejected
        }
    }
}
