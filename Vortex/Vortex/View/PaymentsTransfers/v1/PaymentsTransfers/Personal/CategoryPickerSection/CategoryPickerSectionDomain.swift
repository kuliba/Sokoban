//
//  CategoryPickerSectionDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.09.2024.
//

import Foundation
import PayHubUI

enum CategoryPickerSectionDomain {
 
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias Composer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias ContentDomain = CategoryPickerContentDomain<ServiceCategory>
    typealias Content = ContentDomain.Content
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
        
    typealias Select = ServiceCategory
    
    typealias Navigation = SelectedCategoryNavigation
}
