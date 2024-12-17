//
//  FraudNoticePayload.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

struct FraudNoticePayload: Equatable {
    
    let title: String
    let subtitle: String?
    let formattedAmount: String
    let delay: Double
}
