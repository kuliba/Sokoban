//
//  SegmentedPaymentProvider.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

struct SegmentedPaymentProvider: Equatable, Identifiable {
    
    let id: String
    let icon: String?
    let inn: String?
    let title: String
    let segment: String
    let origin: Origin
    
    enum Origin: Equatable {
        
        case `operator`(OperatorGroupData.OperatorData)
        case provider(CachingSberOperator)
    }
}
