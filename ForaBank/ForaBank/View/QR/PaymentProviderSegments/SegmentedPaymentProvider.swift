//
//  SegmentedPaymentProvider.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

struct SegmentedPaymentProvider: Equatable, Identifiable {
    
    let id: String
    let icon: String
    let title: String
    let inn: String?
    let segment: String
}
