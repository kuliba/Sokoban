//
//  LoadablePickerModel.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import PayHub
import RxViewModel

public typealias LoadablePickerModel<ID, Item> = RxViewModel<LoadablePickerState<ID, Item>, LoadablePickerEvent<Item>, LoadablePickerEffect> where ID: Hashable
