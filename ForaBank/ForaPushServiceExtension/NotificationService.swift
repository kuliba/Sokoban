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
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        let content = UNMutableNotificationContent()
        content.body = request.content.body.description
        content.userInfo = request.content.userInfo
        bestAttemptContent = content
        
        guard let push = try? Push(decoding: request.content.userInfo) else {
            contentHandler(content)
            return
        }
        
#if DEBUG
        let enviroment = ServerAgentEnvironment.test
        
#elseif MOCK
        let enviroment = ServerAgentEnvironment.mock
#else
        let enviroment = ServerAgentEnvironment.prod
#endif
        
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
