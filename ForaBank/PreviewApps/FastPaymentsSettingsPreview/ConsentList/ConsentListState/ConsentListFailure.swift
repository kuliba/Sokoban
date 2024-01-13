//
//  ConsentListFailure.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

enum ConsentListFailure: Error, Equatable {
    
    case collapsedError
    case expandedError
    
    func toggled() -> Self {
        
        switch self {
        case .collapsedError:
            return .expandedError
            
        case .expandedError:
            return .collapsedError
        }
    }
}
