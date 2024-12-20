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
        
        let composer = PlainPickerComposer<Select>(scheduler: schedulers.main)
        
        self.init(
            delay: delay,
            getNavigation: getNavigation,
            makeContent: { composer.compose(elements: elements) },
            schedulers: schedulers,
            witnesses: .init(
                emitting: { $0.$state.compactMap(\.selection) },
                dismissing: { content in { content.event(.select(nil)) }}
            )
        )
    }
}

