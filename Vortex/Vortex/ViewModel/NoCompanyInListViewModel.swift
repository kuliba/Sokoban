//
//  NoCompanyInListViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 16.05.2023.
//

import SwiftUI

class NoCompanyInListViewModel {
    
    let title: String
    let content: String
    let subtitle: String
    var buttons: [ButtonSimpleView.ViewModel]

    init(title: String, content: String, subtitle: String, addCompanyAction: @escaping () -> Void, requisitesAction: @escaping () -> Void) {
        
        self.title = title
        self.content = content
        self.subtitle = subtitle
        self.buttons = [
            ButtonSimpleView.ViewModel(title: "Оплатить по реквизитам", style: .gray, action: requisitesAction),
            ButtonSimpleView.ViewModel(title: "Добавить организацию", style: .gray, action: addCompanyAction)
        ]
    }
}

extension NoCompanyInListViewModel {
    
    static let defaultTitle = "Нет компании в списке?"
    static let defaultContent = "Воспользуйтесь другими способами оплаты"
    static let defaultSubtitle = "Сообщите нам, и мы подключим новую организацию"
}
