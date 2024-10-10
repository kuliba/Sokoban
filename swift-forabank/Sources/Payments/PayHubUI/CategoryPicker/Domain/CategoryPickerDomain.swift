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
public enum CategoryPickerDomain<Category, QRSelect, Navigation> {}

public extension CategoryPickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<ContentDomain.Content, FlowDomain.Flow>
    typealias BinderComposer = CategoryPickerBinderComposer<Category, QRSelect, Navigation>

    // MARK: - Content
    
    typealias ContentDomain = CategoryPickerContentDomain<Category>
    
    // MARK: - Flow
    
    enum Select {
        
        case category(Category)
        case qrSelect(QRSelect)
    }

    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
}

extension CategoryPickerDomain.Select: Equatable where Category: Equatable, QRSelect: Equatable {}
