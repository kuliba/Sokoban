//
//  CategoryPickerSectionFlowDomain.swift
//  
//
//  Created by Igor Malyarov on 28.09.2024.
//

import PayHub
import RxViewModel

/// A namespace.
public typealias CategoryPickerSectionFlowDomain<Category, Navigation> = FlowDomain<CategoryPickerSectionItem<Category, [Category]>, Navigation>
