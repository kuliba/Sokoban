//
//  CategoryPicker.swift
//
//
//  Created by Igor Malyarov on 08.10.2024.
//

import Foundation
import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPicker<Category, List, Navigation> {}

public extension CategoryPicker {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<ContentDomain.Content, FlowDomain.Flow>
    typealias BinderComposer = CategoryPickerBinderComposer<Category, List, Navigation>

    // MARK: - Content
    
    typealias ContentDomain = CategoryPickerContentDomain<Category, List>
    
    // MARK: - Flow
    
    typealias Select = CategoryPickerItem<Category, [Category]>
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
}
