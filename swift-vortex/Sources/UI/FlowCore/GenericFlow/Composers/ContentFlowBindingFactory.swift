//
//  ContentFlowBindingFactory.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import Foundation
import RxViewModel

/// A factory for establishing bindings between `Content` and a `Flow`.
///
/// This class provides multiple `bind` methods that allow content-emitted
/// events to be forwarded to the flow, and vice versa. It can handle simple
/// scenarios without `isLoading` or `dismiss`, or more complex ones that
/// include these events.
public enum ContentFlowBindingFactory {}

public extension ContentFlowBindingFactory {
    
    /// Returns a function `(Content, Flow) -> Set<AnyCancellable>` that binds
    /// `Content` to `Flow` using the given `ContentFlowWitnesses`.
    static func bind<Content, Flow, Select, Navigation>(
        with witnesses: ContentFlowWitnesses<Content, Flow, Select, Navigation>
    ) -> (Content, Flow) -> Set<AnyCancellable> {
        
        return witnesses.bind(content:flow:)
    }
    
    /// Binds `Content` and a flow (`RxViewModel`) using `ContentWitnesses<Content, Select>`.
    ///
    /// - Warning: This variant does not handle `isLoading` or `dismiss` events.
    static func bind<Content, Select, Navigation>(
        content: Content,
        flow: RxViewModel<FlowState<Navigation>, FlowEvent<Select, Navigation>, FlowEffect<Select>>,
        witnesses: ContentWitnesses<Content, Select>
    ) -> Set<AnyCancellable> {
        
        return witnesses.bind(content: content, flow: flow)
    }
    
    /// Binds `Content` and a flow (`RxViewModel`) using `ContentWitnesses<Content, FlowEvent<Select, Never>>`.
    ///
    /// This variant can handle `isLoading` or `dismiss` as part of the `FlowEvent`.
    static func bind<Content, Select, Navigation>(
        content: Content,
        flow: RxViewModel<FlowState<Navigation>, FlowEvent<Select, Navigation>, FlowEffect<Select>>,
        witnesses: ContentWitnesses<Content, FlowEvent<Select, Never>>
    ) -> Set<AnyCancellable> {
        
        return witnesses.bind(content: content, flow: flow)
    }
}
