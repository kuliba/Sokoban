//
//  NotificationService.swift
//  ForaPushServiceExtension
//
//  Created by Роман Воробьев on 03.05.2022.
//

import UserNotifications

final class NotificationService: UNNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
       
        let content = UNMutableNotificationContent()
        content.body = request.content.body.description
        
        if let cloudId = request.content.userInfo[Push.CodingKeys.cloudId.rawValue] as? String, let eventId = request.content.userInfo[Push.CodingKeys.eventId.rawValue] as? String {

            guard let requestUrl = try? RouterUrlList.changeNotificationStatus.returnUrl().get() else { return }

            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"

            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let notificationStatus = NotificationStatusData(eventId: eventId, cloudId: cloudId, status: .delivered)
            let jsonData = try? JSONEncoder().encode(notificationStatus)

            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
        
        contentHandler(content)
    }
}
