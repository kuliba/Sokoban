//
//  NotificationService.swift
//  ForaPushServiceExtension
//
//  Created by Роман Воробьев on 03.05.2022.
//

import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let defaults = UserDefaults(suiteName: "group.com.isimplelab.isimplemobile.forabank")

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        var count: Int = defaults?.integer(forKey: "badgesCount") ?? 0
        self.contentHandler = contentHandler
        let content = UNMutableNotificationContent()
        content.body = request.content.body.description
        content.userInfo = request.content.userInfo
        count = count + 1
        content.badge = count as NSNumber
        defaults?.set(count, forKey: "badgesCount")
        bestAttemptContent = content
        
        guard let push = try? Push(decoding: request.content.userInfo) else {
            contentHandler(content)
            return
        }
        
        let enviroment = Config.serverAgentEnvironment
        
        guard let url = URL(string: enviroment.baseURL + "/notification/changeNotificationStatus") else {
            contentHandler(content)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let notificationStatus = NotificationStatusData(push: push)
        let jsonData = try? JSONEncoder().encode(notificationStatus)
        
        request.httpBody = jsonData
        
        let task =  URLSession.shared.dataTask(with: request) { data, response, error in
            
            contentHandler(content)
        }
        
        task.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = self.bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
