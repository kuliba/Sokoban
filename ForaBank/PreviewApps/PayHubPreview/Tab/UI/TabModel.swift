//
//  TabModel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import RxViewModel

typealias TabModel<Content> = RxViewModel<TabState<Content>, TabEvent<Content>, TabEffect>

