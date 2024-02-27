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
