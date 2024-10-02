//
//  MarketShowcaseContentWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import MarketShowcase
import RxViewModel
import LandingUIComponent

typealias MarketShowcaseContentWrapperView = RxWrapperView<MarketShowcaseContentView<SpinnerRefreshView, LandingWrapperViewModel, LandingWrapperView, MarketShowcaseDomain.Landing>, MarketShowcaseContentState<MarketShowcaseDomain.Landing>, MarketShowcaseContentEvent<MarketShowcaseDomain.Landing>, MarketShowcaseContentEffect>
