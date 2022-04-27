//
//  AccountCellDefaultViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 25.04.2022.
//

import SwiftUI

class AccountCellDefaultViewModel: Identifiable {
    
    let id: UUID
    let icon: Image
    let content: String
    let title: String?
    
    internal init(id: UUID = UUID(), icon: Image, content: String, title: String? = nil) {
        self.id = id
        self.icon = icon
        self.content = content
        self.title = title
    }
    
}
