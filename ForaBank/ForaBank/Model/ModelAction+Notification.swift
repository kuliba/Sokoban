//
//  ModelAction+Notification.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 17.03.2022.
//

import Foundation

extension ModelAction {
    
    enum Notification {

        enum ChangeNotificationStatus {

            struct Requested: Action {
                
                let eventId: String
                let cloudId: String
                let status: ServerCommands.NotificationController.ChangeNotificationStatus.CodingKeys
            }
            
            struct Complete: Action {}
            
            struct Failed: Action {
                
                let error: Error
            }
        }
    }
}
