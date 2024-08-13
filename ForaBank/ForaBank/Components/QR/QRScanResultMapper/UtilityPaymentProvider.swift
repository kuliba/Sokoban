//
//  UtilityPaymentProvider.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

import Foundation

struct UtilityPaymentProvider: Equatable, Identifiable {
    
    let id: String
    let icon: String?
    let inn: String?
    let title: String
    let segment: String
}
