//
//  Alerts.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 29.10.2024.
//

import Foundation

struct Alerts {
    
    var notRequered: [NotReuqeredAlert] = []
    var requered: ReuqeredAlert?
    
    var alert: Alert? {
        
        notRequered.first?.alert ?? requered?.alert
    }
    
    struct ReuqeredAlert: Identifiable {
        
        var id = UUID()
        
        var title: String { .init(id.uuidString.prefix(4)) }
        var alert: Alert { .init(id: id, isRequered: true) }
    }
    
    struct NotReuqeredAlert: Identifiable {
        
        let id = UUID()
        
        var title: String { .init(id.uuidString.prefix(4)) }
        var alert: Alert { .init(id: id, isRequered: false) }
    }
    
    struct Alert: Identifiable {
        
        let id: UUID
        let isRequered: Bool
        
        var title: String { .init(id.uuidString.prefix(4)) }
    }
}
