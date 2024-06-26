//
//  ViewFactory.swift
//
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import UIPrimitives

struct ViewFactory {

    let makeIconView: MakeIconView
}

extension ViewFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
}
