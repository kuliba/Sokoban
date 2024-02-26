//
//  CVVButtonEvent.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 26.02.2024.
//

import UIPrimitives
import ProductProfile

enum CvvButtonEvent {
    
    case showAlert(AlertModelOf<ProductProfileNavigation.Event>)
    case closeAlert
}

extension AlertModelOf<ProductProfileNavigation.Event> {
    
    func cvvAlert() -> AlertModelOf<CvvButtonEvent>? {
                
        return .init(
            id: self.id,
            title: self.title,
            message: self.message,
            primaryButton: .init(
                type: .cancel,
                title: self.primaryButton.title,
                event: .closeAlert
            )
        )
    }
}
