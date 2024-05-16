//
//  IconDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.05.2024.
//

import UIPrimitives

enum IconDomain {
    
    enum Icon {
        
        case md5Hash(MD5Hash)
    }
    
    typealias MakeIconView = (Icon) -> UIPrimitives.AsyncImage
}
