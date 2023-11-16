//
//  Navigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

enum Navigation: Hashable & Identifiable {
    
    case fullScreenCover(FullScreenCover)
    
    var id: Self { self }
    
    enum FullScreenCover: Hashable & Identifiable {
        
        case qrReader

        var id: Self { self }
    }
}

extension Navigation {
    
    var fullScreenCover: FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = self
        else { return nil }
        
        return fullScreenCover
    }
}
