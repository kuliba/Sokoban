//
//  RxObservingViewModel+ext.swift
//
//
//  Created by Igor Malyarov on 20.04.2024.
//

import ForaTools

public extension RxObservingViewModel {
    
    convenience init(
        observable: ObservableViewModel,
        observe: @escaping (State) -> Void,
        predicate: @escaping (State, State) -> Bool = { _,_ in false },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            observable: observable,
            observe: { _, last in observe(last) },
            predicate: predicate,
            scheduler: scheduler
        )
    }
}

public extension RxObservingViewModel {
    
    typealias Reduce = ObservableViewModel.Reduce
    typealias HandleEffect = ObservableViewModel.HandleEffect
    
    convenience init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        predicate: @escaping (State, State) -> Bool = { _,_ in false },
        observe: @escaping Observe,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            observable: .init(
                initialState: initialState,
                reduce: reduce,
                handleEffect: handleEffect,
                predicate: predicate,
                scheduler: scheduler
            ),
            observe: observe,
            predicate: predicate,
            scheduler: scheduler
        )
    }
    
    convenience init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        predicate: @escaping (State, State) -> Bool = { _,_ in false },
        observe: @escaping (State) -> Void,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            observable: .init(
                initialState: initialState,
                reduce: reduce,
                handleEffect: handleEffect,
                predicate: predicate,
                scheduler: scheduler
            ),
            observe: { _, last in observe(last) },
            predicate: predicate,
            scheduler: scheduler
        )
    }
}

public extension RxObservingViewModel where State: Equatable {
    
    convenience init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        observe: @escaping Observe,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            observable: .init(
                initialState: initialState,
                reduce: reduce,
                handleEffect: handleEffect,
                scheduler: scheduler
            ),
            observe: observe,
            predicate: ==,
            scheduler: scheduler
        )
    }
    
    convenience init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        observe: @escaping (State) -> Void,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            observable: .init(
                initialState: initialState,
                reduce: reduce,
                handleEffect: handleEffect,
                scheduler: scheduler
            ),
            observe: { _, last in observe(last) },
            predicate: ==,
            scheduler: scheduler
        )
    }
}
