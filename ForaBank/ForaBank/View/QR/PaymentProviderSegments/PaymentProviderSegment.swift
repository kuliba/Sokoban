//
//  PaymentProviderSegment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.07.2024.
//

struct PaymentProviderSegment: Equatable, Identifiable {
    
    let title: String
    let providers: [Provider]
    
    struct Provider: Equatable, Identifiable {
        
        let id: String
        let icon: String
        let title: String
        let inn: String?
    }
    
    var id: String { title }
}
