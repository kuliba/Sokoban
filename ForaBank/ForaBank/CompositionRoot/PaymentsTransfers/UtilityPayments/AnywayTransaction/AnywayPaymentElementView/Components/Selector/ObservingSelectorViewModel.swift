//
//  ObservingSelectorViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import RxViewModel

typealias ObservingSelectorViewModel<T> = RxObservingViewModel<Selector<T>, SelectorEvent<T>, Never>
