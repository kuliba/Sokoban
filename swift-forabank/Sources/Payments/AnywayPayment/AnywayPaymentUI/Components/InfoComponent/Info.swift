//
//  Info.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

struct Info<Icon> {
    
    let icon: Icon
    let title: String
    let subtitle: String
}

extension Info: Equatable where Icon: Equatable {}
