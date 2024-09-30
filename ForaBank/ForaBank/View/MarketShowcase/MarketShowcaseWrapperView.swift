//
//  MarketShowcaseWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import MarketShowcase
import RxViewModel

typealias MarketShowcaseWrapperView = RxWrapperView<MarketShowcaseFlowView<MarketShowcaseContentWrapperView, MarketShowcaseDomain.Destination, MarketShowcaseDomain.InformerPayload>, MarketShowcaseFlowState<MarketShowcaseDomain.Destination, MarketShowcaseDomain.InformerPayload>, MarketShowcaseFlowEvent<MarketShowcaseDomain.Destination, MarketShowcaseDomain.InformerPayload>, MarketShowcaseFlowEffect>
