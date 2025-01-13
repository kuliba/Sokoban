//
//  OperationPickerDomain.swift
//  
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation
import PayHub

public typealias OperationPickerState<Latest> = LoadablePickerState<UUID, OperationPickerElement<Latest>>
public typealias OperationPickerEvent<Latest> = LoadablePickerEvent<OperationPickerElement<Latest>>
public typealias OperationPickerEffect = LoadablePickerEffect
