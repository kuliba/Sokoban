//
//  PayHubTypes.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import RxViewModel

// MARK: - PayHub Content

typealias PayHubState = LoadablePickerState<UUID, PayHubItem<Latest>>
typealias PayHubEvent = LoadablePickerEvent<PayHubItem<Latest>>
typealias PayHubEffect = LoadablePickerEffect

typealias PayHubReducer = LoadablePickerReducer<UUID, PayHubItem<Latest>>
typealias PayHubEffectHandler = LoadablePickerEffectHandler<PayHubItem<Latest>>

typealias PayHubContent = RxViewModel<PayHubState, PayHubEvent, PayHubEffect>

// MARK: - PayHub Flow

typealias PayHubFlowState = PayHub.PayHubFlowState<Exchange, LatestFlow, Status, Templates>
typealias PayHubFlowEvent = PayHub.PayHubFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubFlowEffect = PayHub.PayHubFlowEffect<Latest>

typealias PayHubFlowReducer = PayHub.PayHubFlowReducer<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubFlowEffectHandler = PayHub.PayHubFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>

typealias PayHubFlow = RxViewModel<PayHubFlowState, PayHubFlowEvent, PayHubFlowEffect>
