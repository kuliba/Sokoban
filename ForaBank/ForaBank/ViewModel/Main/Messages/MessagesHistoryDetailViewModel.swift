//
//  MessagesHistoryDetailViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.06.2022.
//

import SwiftUI

struct MessagesHistoryDetailViewModel: Identifiable {
    
    let id = UUID()
    let title: String
    let content: String
    let icon: Image
    
    init(item: MessagesHistoryItemView.ViewModel) {
        
        self.title = item.title
        self.content = item.content
        self.icon = Image("Payments List Sample")
    }
    
}
