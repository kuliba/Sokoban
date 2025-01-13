//
//  FastPaymentsSettingsState+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

public extension FastPaymentsSettingsState {
    
    var isInflight: Bool {
        
        get { status == .inflight }
        set(newValue) { status = .inflight }
    }
}
