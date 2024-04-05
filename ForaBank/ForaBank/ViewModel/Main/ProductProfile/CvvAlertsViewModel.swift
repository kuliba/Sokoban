//
//  CvvAlertsViewModel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import Foundation

struct CvvAlertsViewModel {
    
    let title: String
    let blockAlertText: String
    let additionalAlertText: String
}

extension CvvAlertsViewModel {
    
    static let `default`: Self = .init(
        title: "Информация",
        blockAlertText: "Для просмотра CVV и смены PIN карта должна быть активна.",
        additionalAlertText: "CVV может увидеть только человек,\nна которого выпущена карта.\nЭто мера предосторожности во избежание мошеннических операций."
    )
}
