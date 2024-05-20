//
//  OperationInfo.swift
//  
//
//  Created by Igor Malyarov on 19.05.2024.
//

public enum OperationInfo<DetailID, Details> {
    
    /// `paymentOperationDetailId`
    case detailID(DetailID)
    case details(Details)
}


extension OperationInfo: Equatable where DetailID: Equatable, Details: Equatable {}
