//
//  MarketShowcaseWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import RxViewModel
import SwiftUI

public typealias MarketShowcaseContentViewModel<Landing> = RxViewModel<MarketShowcaseContentState<Landing>, MarketShowcaseContentEvent<Landing>, MarketShowcaseContentEffect>

public typealias MarketShowcaseContentWrapperView<RefreshView, Landing> = RxWrapperView<MarketShowcaseView<RefreshView, Landing>, MarketShowcaseContentState<Landing>, MarketShowcaseContentEvent<Landing>, MarketShowcaseContentEffect> where RefreshView: View
