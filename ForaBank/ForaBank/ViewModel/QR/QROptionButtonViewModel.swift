//
//  QROptionButtonViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 24.10.2022.
//

import SwiftUI

class QROptionButtonViewModel: Identifiable {
    
    let id: UUID
    let icon: Image
    let title: String
    let action: () -> Void
    
    internal init(id: UUID, icon: Image, title: String, action: @escaping () -> Void) {
        self.id = id
        self.icon = icon
        self.title = title
        self.action = action
    }
}

