//
//  Destination.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import PayHub

/// A namespace.
enum DestinationDomain {}

extension DestinationDomain {
    
    typealias Content = PlainPickerContent<Element>
    typealias Composer = PlainPickerComposer<Element>
    
    enum Element: Equatable, CaseIterable {
        
        case close
        case next
    }
}
