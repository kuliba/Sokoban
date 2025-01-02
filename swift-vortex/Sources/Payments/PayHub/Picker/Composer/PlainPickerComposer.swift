//
//  PlainPickerComposer.swift
//
//
//  Created by Igor Malyarov on 14.12.2024.
//

import CombineSchedulers
import Foundation

public final class PlainPickerComposer<Element> {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

public extension PlainPickerComposer {
    
    func compose(
        elements: [Element]
    ) -> PlainPickerContent<Element> {
        
        let reducer = PickerContentReducer<Element>()
        let effectHandler = PickerContentEffectHandler<Element>()
        
        return .init(
            initialState: .init(elements: elements),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
