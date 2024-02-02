//
//  TransferResponseBaseData.swift
//  ForaBank
//
//  Created by Max Gribov on 31.01.2022.
//

import Foundation

class TransferResponseBaseData: Codable {

    //FIXME: not optional in MakeTransferResponseDto, but optional in CreateTransferResponseDto
    let documentStatus: DocumentStatus? //
    let paymentOperationDetailId: Int
    
    internal init(documentStatus: TransferResponseBaseData.DocumentStatus?, paymentOperationDetailId: Int) {
        self.documentStatus = documentStatus
        self.paymentOperationDetailId = paymentOperationDetailId
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case  documentStatus, paymentOperationDetailId
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        documentStatus = try container.decodeIfPresent(DocumentStatus.self, forKey: .documentStatus)
        paymentOperationDetailId = try container.decode(Int.self, forKey: .paymentOperationDetailId)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(documentStatus, forKey: .documentStatus)
        try container.encode(paymentOperationDetailId, forKey: .paymentOperationDetailId)
    }
}


//MARK: - Types

extension TransferResponseBaseData {
    
    enum DocumentStatus: String, Codable, Equatable, Unknownable {
        
        case complete = "COMPLETE"
        case inProgress = "IN_PROGRESS"
        case rejected = "REJECTED"
        case suspended = "SUSPEND"
        case unknown
    }
}

//MARK: - Equitable

extension TransferResponseBaseData: Equatable {
    
    static func == (lhs: TransferResponseBaseData, rhs: TransferResponseBaseData) -> Bool {
        
        return lhs.documentStatus == rhs.documentStatus &&
               lhs.paymentOperationDetailId == rhs.paymentOperationDetailId
    }
}
