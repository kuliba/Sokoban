//
//  QRLink.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.09.2023.
//

import Tagged

struct QRLink: Equatable {
    
    let link: Link
    
    typealias Link = Tagged<_Link, String>

    enum _Link {}
    
    var isEmpty: Bool { link.isEmpty }
}
