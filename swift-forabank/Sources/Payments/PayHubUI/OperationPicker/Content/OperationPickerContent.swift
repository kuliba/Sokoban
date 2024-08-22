//
//  OperationPickerContent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import RxViewModel

public typealias OperationPickerState<Latest> = LoadablePickerState<UUID, OperationPickerItem<Latest>>
public typealias OperationPickerEvent<Latest> = LoadablePickerEvent<OperationPickerItem<Latest>>
public typealias OperationPickerEffect = LoadablePickerEffect

public typealias OperationPickerReducer<Latest> = LoadablePickerReducer<UUID, OperationPickerItem<Latest>>
public typealias OperationPickerEffectHandler<Latest> = LoadablePickerEffectHandler<OperationPickerItem<Latest>>

public typealias OperationPickerContent<Latest> = RxViewModel<OperationPickerState<Latest>, OperationPickerEvent<Latest>, OperationPickerEffect>
