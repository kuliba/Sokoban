//
//  UtilityService.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Foundation

struct UtilityService<Icon>: Identifiable {
    
    let id: String
    let name: String
    let icon: Icon
}

extension UtilityService: Equatable where Icon: Equatable {}
