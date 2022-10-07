//
//  MessagesHistoryDetailViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.06.2022.
//

import SwiftUI

struct MessagesHistoryDetailViewModel: Identifiable {
    
    let id: NotificationData.ID
    let title: String
    let content: String
    let icon: Image
    
    init(id: NotificationData.ID, title: String, content: String, icon: Image) {
        self.id = id
        self.title = title
        self.content = content
        self.icon = icon
    }
    
    init(notificationData: NotificationData) {
        
        self.title = notificationData.type.rawValue + " " + notificationData.title
        self.content = notificationData.text
        self.icon = Image.ic24MoreHorizontal
        self.id = notificationData.id
    }
}
