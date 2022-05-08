//
//  NotificationService.swift
//  ForaPushServiceExtension
//
//  Created by Роман Воробьев on 03.05.2022.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let cloudID = "\(bestAttemptContent.userInfo["cloud_id"] ?? "empty")"
            let eventID = "\( bestAttemptContent.userInfo["event_id"] ?? "empty")"
            
            ApiRequestsForPush.changeNotificationStatus (eventId: eventID, cloudId: cloudID, status: "DELIVERED") { model, error in
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
