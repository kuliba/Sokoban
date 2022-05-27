//
//  NotificationData.swift
//  ForaBank
//
//  Created by Max Gribov on 03.02.2022.
//

import Foundation

struct NotificationData: Equatable {
    
    var date: Date
    let title: String
    let state: State
    let text: String
    let type: Kind
    
    var sortIndex: Int? {
        
        let componets = calendarComponents(date)
        
        guard let hour = componets?.hour,
              let minute = componets?.minute,
              let second = componets?.second
        else { return nil }
        
        let result = join(with: hour, minute, second)
        
        return result
    }
    
    var groupIndex: Int? {
        
        let componets = calendarComponents(date)
        
        guard let year = componets?.year,
              let month = componets?.month,
              let day = componets?.day
        else { return nil }
        
        let result = join(with: year, month, day)
        
        return result
    }
    
    enum State: String, Codable, Equatable {
        
        case delivered = "DELIVERED"
        case error = "ERROR"
        case inProgress = "IN_PROGRESS"
        case new = "NEW"
        case read = "READ"
        case sent = "SENT"
    }
    
    enum Kind: String, Codable, Equatable {
        
        case email = "EMAIL"
        case push = "PUSH"
        case sms = "SMS"
    }
    
    private func calendarComponents (_ date: Date) -> DateComponents? {
        
        let calendar = Calendar.current
        let componets = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return componets
    }
    
    private func join (with values: Int ... ) -> Int {
        
        var total: Int = 0
        for value in values {
            total += value
            total = total * 100
        }
        return total / 100
    }
}

//MARK: - Codable

extension NotificationData: Codable {
    
    private enum CodingKeys : String, CodingKey {
        case date, title, state, text, type
    }
    
    init(from decoder: Decoder) throws {
        
        let formatter = DateFormatter.dateAndTime
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .date)
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.unableDecodeDate
        }
        self.date = date
        self.state = try container.decode(State.self, forKey: .state)
        self.text = try container.decode(String.self, forKey: .text)
        self.type = try container.decode(Kind.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
    }
    
    func encode(to encoder: Encoder) throws {
        
        let formatter = DateFormatter.dateAndTime
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(formatter.string(from: date), forKey: .date)
        try container.encode(state, forKey: .state)
        try container.encode(text, forKey: .text)
        try container.encode(text, forKey: .title)
        try container.encode(type, forKey: .type)
    }
    
    enum DecodingError: Error {
        case unableDecodeDate
    }
}

//MARK: - Hashable

extension NotificationData: Hashable {
    
    static func == (lhs: NotificationData, rhs: NotificationData) -> Bool {
        return lhs.date == rhs.date
               && lhs.text == rhs.text
               && lhs.state == rhs.state
               && lhs.type == rhs.type
               
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(text)
        hasher.combine(state)
        hasher.combine(type)
    }
}
