//
//  MarketShowcaseFlowWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import MarketShowcase
import RxViewModel

typealias MarketShowcaseFlowWrapperView = RxWrapperView<MarketShowcaseContentWrapperView, MarketShowcaseFlowState<MarketShowcaseDomain.Destination, MarketShowcaseDomain.InformerPayload>, MarketShowcaseFlowEvent<MarketShowcaseDomain.Destination, MarketShowcaseDomain.InformerPayload>, MarketShowcaseFlowEffect>
