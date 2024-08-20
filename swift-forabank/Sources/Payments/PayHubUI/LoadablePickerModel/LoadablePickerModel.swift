//
//  LoadablePickerModel.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation
import PayHub
import RxViewModel

public typealias LoadablePickerModel<Item> = RxViewModel<LoadablePickerState<UUID, Item>, LoadablePickerEvent<Item>, LoadablePickerEffect>
