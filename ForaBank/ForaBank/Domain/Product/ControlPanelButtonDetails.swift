//
//  ControlPanelButtonDetails.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation

import SwiftUI

struct ControlPanelButtonDetails: Equatable {
    
    let id: ProductData.ID
    let title: String
    let icon: Image?
    let event: ControlButtonEvent
}

extension ControlPanelButtonDetails {
    
    typealias Event = ControlButtonEvent
}
