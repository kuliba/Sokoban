//
//  PlainPickerBinderComposer.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

public typealias PlainPickerBinderComposer<Element, Navigation> = BinderComposer<PlainPickerContent<Element>, Element, Navigation>

public extension PlainPickerBinderComposer {
    
    convenience init(
        elements: [Select],
        delay: Delay = .milliseconds(100),
        getNavigation: @escaping GetNavigation,
        schedulers: Schedulers = .init()
    ) where Content == PlainPickerContent<Select> {
        
        let reducer = PickerContentReducer<Select>()
        let effectHandler = PickerContentEffectHandler<Select>()
        
        let content = PlainPickerContent<Select>(
            initialState: .init(elements: elements),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: schedulers.main
        )
        
        self.init(
            delay: delay,
            getNavigation: getNavigation,
            makeContent: { content },
            schedulers: schedulers,
            witnesses: .init(
                emitting: { $0.$state.compactMap(\.selection) },
                dismissing: { content in { content.event(.select(nil)) }}
            )
        )
    }
}
