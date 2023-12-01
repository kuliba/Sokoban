//
//  Route.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

import Foundation

struct Route: Equatable {
    
    var destination: Destination?
    var modal: Modal?
    
    static let empty: Self = .init(destination: nil, modal: nil)
}

extension Route {
    
    enum Destination: Hashable & Identifiable {
        
        case sberQRPayment(URL)
        
        var id: Self { self }
    }
    
    enum Modal: Hashable & Identifiable {
        
        case alert(Alert)
        case fullScreenCover(FullScreenCover)
        case sheet(Sheet)
        
        var id: Self { self }
    }
}

extension Route.Modal {
    
    struct Alert: Hashable & Identifiable {
        
        let message: String
        
        var id: Self { self }
    }
    
    enum FullScreenCover: Hashable & Identifiable {
        
        case qrReader
        
        var id: Self { self }
    }
    
    enum Sheet: Hashable & Identifiable {
        
        case picker(Wrapped)
        case sberQRPayment(URL)
        
        var id: Self { self }
        
        struct Wrapped: Identifiable & Hashable {
            
            let id = UUID()
            let closure: (String) -> Void
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                
                lhs.id == rhs.id
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(id)
            }
        }
    }
}

extension Route {
    
    var alert: Modal.Alert? {
        
        guard case let .alert(alert) = modal
        else { return nil }
        
        return alert
    }
    
    var fullScreenCover: Modal.FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = modal
        else { return nil }
        
        return fullScreenCover
    }
    
    var sheet: Modal.Sheet? {
        
        guard case let .sheet(sheet) = modal
        else { return nil }
        
        return sheet
    }
}
