//
//  Factory.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

struct Factory {
    
    let makeFastPaymentsSettingsViewModel: MakeFastPaymentsSettingsViewModel
}

extension Factory {
    
    typealias MakeFastPaymentsSettingsViewModel = () -> FastPaymentsSettingsViewModel
}
