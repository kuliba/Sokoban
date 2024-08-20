//
//  PayHubPickerBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation
import PayHub
import RxViewModel

// MARK: - Content

typealias Latest = UtilityPaymentLastPayment

typealias PayHubPickerState = LoadablePickerState<UUID, PayHubPickerItem<Latest>>
typealias PayHubPickerEvent = LoadablePickerEvent<PayHubPickerItem<Latest>>
typealias PayHubPickerEffect = LoadablePickerEffect

typealias PayHubPickerReducer = LoadablePickerReducer<UUID, PayHubPickerItem<Latest>>
typealias PayHubPickerEffectHandler = LoadablePickerEffectHandler<PayHubPickerItem<Latest>>

typealias PayHubPickerContent = RxViewModel<PayHubPickerState, PayHubPickerEvent, PayHubPickerEffect>

// MARK: - Flow

// TODO: fixme
typealias PayHubPickerFlow = Void

// MARK: - Binder

typealias PayHubPickerBinder = PayHub.Binder<PayHubPickerContent, PayHubPickerFlow>
