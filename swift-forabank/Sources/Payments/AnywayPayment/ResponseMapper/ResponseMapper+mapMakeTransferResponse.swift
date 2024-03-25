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
    ) -> MakeTransferResponse? {
        
        try? map(data, httpURLResponse, mapOrThrow: MakeTransferResponse.init).get()
    }
}

extension ResponseMapper {
    
    public struct MakeTransferResponse {
        
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
        
        case complete = "COMPLETE"
        case inProgress = "IN_PROGRESS"
        case rejected = "REJECTED"
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
        case .complete:
            self = .complete
        case .inProgress:
            self = .inProgress
        case .rejected:
            self = .rejected
        }
    }
}
