//
//  SelectorViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import RxViewModel

typealias ObservingSelectorViewModel<T> = RxObservingViewModel<Selector<T>, SelectorEvent<T>, Never>
typealias SelectorViewModel<T> = RxViewModel<Selector<T>, SelectorEvent<T>, Never>
