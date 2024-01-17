//
//  Consent+ext.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

public extension Consent {
    
    static let preview: Self = .init(
        [ConsentList.SelectableBank].preview.prefix(2).map(\.id)
    )
}
