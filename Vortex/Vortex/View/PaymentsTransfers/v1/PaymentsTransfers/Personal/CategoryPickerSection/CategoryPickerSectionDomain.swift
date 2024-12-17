//
//  CategoryPickerSectionDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.09.2024.
//

import Foundation
import PayHub
import PayHubUI

enum CategoryPickerSectionDomain {
 
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias Composer = PayHub.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias ContentDomain = CategoryPickerContentDomain<ServiceCategory>
    typealias Content = ContentDomain.Content
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
        
    typealias Select = ServiceCategory
    
    typealias Navigation = SelectedCategoryNavigation
}
