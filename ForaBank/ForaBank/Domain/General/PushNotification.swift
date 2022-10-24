//
//  Notification.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 28.09.2022.
//

import Foundation

struct Push: Decodable {
    
    let eventId: String
    let cloudId: String
    let aps: APS?
    let body: String?
    let google: String
    let messageId: String
    let notificationQueueId: String?
    let code: String?
    let googleSender: String?
    let googleFid: String?
    
    struct APS: Decodable {
        
        let alert: Alert
        let badge: Int
        let available: Int
        let mutable: Int
        
        enum CodingKeys: String, CodingKey {
            
            case alert, badge
            case available = "content-available"
            case mutable = "mutable-content"
        }
        
        struct Alert: Decodable {
            
            let title: String?
            let body: String
            
            enum CodingKeys: String, CodingKey {
                
                case title, body
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        
        case eventId = "event_id"
        case google = "google.c.a.e"
        case messageId = "gcm.message_id"
        case code = "otp"
        case cloudId = "cloud_id"
        case googleSender = "google.c.sender.id"
        case googleFid = "google.c.fid"
        case body, notificationQueueId, aps
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventId = try container.decode(String.self, forKey: .eventId)
        cloudId = try container.decode(String.self, forKey: .cloudId)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        messageId = try container.decode(String.self, forKey: .messageId)
        notificationQueueId = try container.decodeIfPresent(String.self, forKey: .notificationQueueId)
        google = try container.decode(String.self, forKey: .google)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        aps = try container.decode(APS.self, forKey: .aps)
        googleFid = try container.decodeIfPresent(String.self, forKey: .googleFid)
        googleSender = try container.decodeIfPresent(String.self, forKey: .googleSender)
    }
    
    init(decoding userInfo: [AnyHashable : Any]) throws {
        
        let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        self = try JSONDecoder().decode(Push.self, from: data)
    }
}

struct NotificationStatusData: Encodable {
    
    let eventId: String
    let cloudId: String
    let status: NotificationStatus
    
    internal init(eventId: String, cloudId: String, status: NotificationStatus) {
        self.eventId = eventId
        self.cloudId = cloudId
        self.status = status
    }
    
    init(push: Push) {
        
        self.cloudId = push.cloudId
        self.eventId = push.eventId
        self.status = .delivered
    }
}
