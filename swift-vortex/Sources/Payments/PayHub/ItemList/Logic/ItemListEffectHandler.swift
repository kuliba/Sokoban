//
//  ItemListEffectHandler.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

import VortexTools

public typealias LoadState = VortexTools.LoadState

public typealias ItemListEffectHandler<Entity> = LoadablePickerEffectHandler<Stateful<Entity, LoadState>>
