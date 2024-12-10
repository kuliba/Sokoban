//
//  UtilityPaymentProvider.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct UtilityPaymentProvider: Equatable, Identifiable {
    
    let id: String
    let icon: String?
    let inn: String
    let title: String
    let type: String
}

extension UtilityPaymentProvider {
    
    var subtitle: String { inn }
}
