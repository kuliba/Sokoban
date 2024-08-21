//
//  ServiceCategory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import Foundation

struct ServiceCategory: Equatable {
    
    let name: String
}

extension ServiceCategory: Identifiable {
    
    var id: String { name }
}
