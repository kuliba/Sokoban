//
//  SavingsAccountContentViewFactory.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import SwiftUI

public struct SavingsAccountContentViewFactory<RefreshView, Landing, LandingView, InformerPayload, InformerView>
where RefreshView: View,
      LandingView: View,
      InformerView: View
{
    
    let refreshView: RefreshView
    let makeInformerView: MakeInformerView
    let makeLandingView: MakeLandingView
    
    public init(
        refreshView: RefreshView,
        makeInformerView: @escaping MakeInformerView,
        makeLandingView: @escaping MakeLandingView
    ) {
        self.refreshView = refreshView
        self.makeInformerView = makeInformerView
        self.makeLandingView = makeLandingView
    }
}

public extension SavingsAccountContentViewFactory {
    
    typealias MakeLandingView = (Landing) -> LandingView
    typealias MakeInformerView = (InformerPayload) -> InformerView
}
