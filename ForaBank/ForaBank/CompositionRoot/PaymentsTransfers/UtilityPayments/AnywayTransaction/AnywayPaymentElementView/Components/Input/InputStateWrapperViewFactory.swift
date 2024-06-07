//
//  InputStateWrapperViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import UIPrimitives

struct InputStateWrapperViewFactory {
    
    let makeIconView: MakeIconView
}

extension InputStateWrapperViewFactory {
    
    typealias MakeIconView = () -> UIPrimitives.AsyncImage
}
