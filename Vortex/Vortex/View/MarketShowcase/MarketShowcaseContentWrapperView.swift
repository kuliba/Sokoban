//
//  MarketShowcaseContentWrapperView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import MarketShowcase
import RxViewModel
import LandingUIComponent

typealias MarketShowcaseContentWrapperView = RxWrapperView<MarketShowcaseContentView<SpinnerRefreshView, LandingWrapperView, MarketShowcaseDomain.Landing, MarketShowcaseDomain.InformerPayload>, MarketShowcaseContentState<MarketShowcaseDomain.Landing, MarketShowcaseDomain.InformerPayload>, MarketShowcaseContentEvent<MarketShowcaseDomain.Landing, MarketShowcaseDomain.InformerPayload>, MarketShowcaseContentEffect>
