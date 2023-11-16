//
//  Navigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

import Foundation

enum Navigation: Hashable & Identifiable {
    
    case alert(Alert)
    case destination(Destination)
    case fullScreenCover(FullScreenCover)
    case sheet(Sheet)
    
    var id: Self { self }
    
    struct Alert: Hashable & Identifiable {
        
        let message: String
        
        var id: Self { self }
    }
    
    enum Destination: Hashable & Identifiable {
        
        case sberQRPayment(URL)
        
        var id: Self { self }
    }
    
    enum FullScreenCover: Hashable & Identifiable {
        
        case qrReader
        
        var id: Self { self }
    }
    
    enum Sheet: Hashable & Identifiable {
        
        case sberQRPayment(URL)
        
        var id: Self { self }
    }
}

extension Navigation {
    
    var alert: Alert? {
        
        guard case let .alert(alert) = self
        else { return nil }
        
        return alert
    }
    
    var destination: Destination? {
        
        guard case let .destination(destination) = self
        else { return nil }
        
        return destination
    }
    
    var fullScreenCover: FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = self
        else { return nil }
        
        return fullScreenCover
    }
    
    var sheet: Sheet? {
        
        guard case let .sheet(sheet) = self
        else { return nil }
        
        return sheet
    }
}
