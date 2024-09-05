//
//  ServiceCategory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import Foundation
import PayHubUI

struct ServiceCategory: Equatable, Named {
    
    let name: String
}

extension ServiceCategory: Identifiable {
    
    var id: String { name }
}
