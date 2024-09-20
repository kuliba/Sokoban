//
//  OperationPickerContent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import RxViewModel

public typealias OperationPickerState<Latest> = LoadablePickerState<UUID, OperationPickerElement<Latest>>
public typealias OperationPickerEvent<Latest> = LoadablePickerEvent<OperationPickerElement<Latest>>
public typealias OperationPickerEffect = LoadablePickerEffect

public typealias OperationPickerReducer<Latest> = LoadablePickerReducer<UUID, OperationPickerElement<Latest>>
public typealias OperationPickerEffectHandler<Latest> = LoadablePickerEffectHandler<OperationPickerElement<Latest>>

public typealias OperationPickerContent<Latest> = RxViewModel<OperationPickerState<Latest>, OperationPickerEvent<Latest>, OperationPickerEffect>
