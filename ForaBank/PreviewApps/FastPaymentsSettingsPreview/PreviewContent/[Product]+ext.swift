//
//  [Product]+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import Foundation

extension Array where Element == Product {
    
    static let preview: Self = [.card, .account]
}
