//
//  SelectedCategoryFailure.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.01.2025.
//

import Foundation

struct SelectedCategoryFailure: Error, Equatable, Identifiable {
    
    let id: UUID
    let message: String
}
