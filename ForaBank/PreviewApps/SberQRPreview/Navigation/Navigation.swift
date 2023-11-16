//
//  Navigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

enum Navigation: Hashable {
    
    case fullScreenCover(FullScreenCover)
    
    enum FullScreenCover: Hashable {
        
        case qrReader
    }
}
