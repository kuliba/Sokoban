//
//  ListHorizontalRectangleLimitsViewFactory.swift
//
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import UIPrimitives

struct ListHorizontalRectangleLimitsViewFactory {

    let makeIconView: MakeIconView
}

extension ListHorizontalRectangleLimitsViewFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
}
