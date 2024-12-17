//
//  NotificationData.swift
//  ForaBank
//
//  Created by Max Gribov on 03.02.2022.
//

import Foundation

struct NotificationData: Equatable, Identifiable, Hashable, Codable {
    
    var id: Int { hashValue }
    
    let title: String
    let state: State
    let text: String
    let type: Kind
    let date: Date

    enum State: String, Codable, Equatable, Hashable, Unknownable {
        
        case delivered = "DELIVERED"
        case error = "ERROR"
        case inProgress = "IN_PROGRESS"
        case new = "NEW"
        case read = "READ"
        case sent = "SENT"
        case unknown
    }
    
    enum Kind: String, Codable, Equatable, Hashable, Unknownable {
        
        case email = "EMAIL"
        case push = "PUSH"
        case sms = "SMS"
        case unknown
    }
    
    private enum CodingKeys : String, CodingKey {
        case title, state, text, type
        case date = "dateISO"
    }
}
