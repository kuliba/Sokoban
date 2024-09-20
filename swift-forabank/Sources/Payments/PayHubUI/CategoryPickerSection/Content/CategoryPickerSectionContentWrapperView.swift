//
//  CategoryPickerSectionContentWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import RxViewModel
import SwiftUI

public typealias CategoryPickerSectionContentWrapperView<ContentView, ServiceCategory> = RxWrapperView<ContentView, CategoryPickerSectionState<ServiceCategory>, CategoryPickerSectionEvent<ServiceCategory>, CategoryPickerSectionEffect> where ContentView: View
