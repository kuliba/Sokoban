//
//  CategoryPickerSection.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import Foundation
import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPickerSection<Category, Navigation> {}

public extension CategoryPickerSection {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<ContentDomain.Content, FlowDomain.Flow>
    typealias BinderComposer = CategoryPickerSectionBinderComposer<Category, Navigation>

    // MARK: - Content
    
    typealias ContentDomain = CategoryPickerSectionContentDomain<Category>
    
    // MARK: - Flow
    
    typealias FlowDomain = CategoryPickerSectionFlowDomain<Category, Navigation>
}
