//
//  NotificationData.swift
//  ForaBank
//
//  Created by Max Gribov on 03.02.2022.
//

import Foundation

struct NotificationData: Equatable, Identifiable, Hashable {
    
    var id: Int { hashValue }
    
    let title: String
    let state: State
    let text: String
    let type: Kind
    let dateUtc: Date

    enum State: String, Codable, Equatable, Hashable {
        
        case delivered = "DELIVERED"
        case error = "ERROR"
        case inProgress = "IN_PROGRESS"
        case new = "NEW"
        case read = "READ"
        case sent = "SENT"
    }
    
    enum Kind: String, Codable, Equatable, Hashable {
        
        case email = "EMAIL"
        case push = "PUSH"
        case sms = "SMS"
    }
}

//MARK: - Codable

extension NotificationData: Codable {
    
    private enum CodingKeys : String, CodingKey {
        case date, title, state, text, type
        case dateUtc = "dateUTC"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateValue = try container.decode(Int.self, forKey: .dateUtc)
        self.dateUtc = Date(timeIntervalSince1970: TimeInterval(dateValue / 1000))
        self.state = try container.decode(State.self, forKey: .state)
        self.text = try container.decode(String.self, forKey: .text)
        self.type = try container.decode(Kind.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(dateUtc.timeIntervalSince1970) * 1000, forKey: .dateUtc)
        try container.encode(state, forKey: .state)
        try container.encode(text, forKey: .text)
        try container.encode(text, forKey: .title)
        try container.encode(type, forKey: .type)
    }
}
