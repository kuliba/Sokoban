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
    
    init(item: MessagesHistoryItemView.ViewModel) {
        
        self.title = item.title
        self.content = item.content
        self.icon = Image.ic16List
        self.id = item.id
    }
    
    init(notificationData: NotificationData) {
        
        self.title = notificationData.title
        self.content = notificationData.text
        self.icon = Image.ic16List
        self.id = notificationData.id
    }
}
