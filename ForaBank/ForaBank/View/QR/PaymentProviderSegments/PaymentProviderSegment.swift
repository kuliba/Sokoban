//
//  PaymentProviderSegment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

struct PaymentProviderSegment<Provider>: Identifiable {
    
    let title: String
    let providers: [Provider]
    
    var id: String { title }
}

extension PaymentProviderSegment: Equatable where Provider: Equatable {}
