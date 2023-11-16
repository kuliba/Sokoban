//
//  Navigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

import Foundation

enum Navigation: Hashable & Identifiable {
    
    case destination(Destination)
    case fullScreenCover(FullScreenCover)
    
    var id: Self { self }
    
    enum Destination: Hashable & Identifiable {
        
        case sberQRPayment(URL)

        var id: Self { self }
    }
    
    enum FullScreenCover: Hashable & Identifiable {
        
        case qrReader
        case sberQRPayment(URL)

        var id: Self { self }
    }
}

extension Navigation {
    
    var destination: Destination? {
        
        guard case let .destination(destination) = self
        else { return nil }
        
        return destination
    }
}

extension Navigation {
    
    var fullScreenCover: FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = self
        else { return nil }
        
        return fullScreenCover
    }
}
