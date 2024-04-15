//
//  ExpandablePickerViewModel.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import RxViewModel

typealias ExpandablePickerViewModel<Item> = RxViewModel<ExpandablePickerState<Item>, ExpandablePickerEvent<Item>, ExpandablePickerEffect> where Item: Equatable
