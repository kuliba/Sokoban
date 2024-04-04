//
//  CvvAlertsFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import Foundation


struct CvvAlertsFactory {
    
    let makeCvvAlertsViewModel: MakeCvvAlertsViewModel
}

extension CvvAlertsFactory {
    
    typealias MakeCvvAlertsViewModel = () -> CvvAlertsViewModel
}

struct CvvAlertsViewModel {
    
    let title: String
    let blockAlertText: String
    let additionalAlertText: String
}

extension CvvAlertsFactory {
    
    static let preview: Self = .init(makeCvvAlertsViewModel: {
        .init(
            title: "Title",
            blockAlertText: "blockAlertText",
            additionalAlertText: "additionalAlertText")
    })
}
