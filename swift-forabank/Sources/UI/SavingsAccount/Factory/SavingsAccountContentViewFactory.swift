//
//  SavingsAccountContentViewFactory.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import SwiftUI

public struct SavingsAccountContentViewFactory<RefreshView, Landing, LandingView>
where RefreshView: View,
      LandingView: View
{
    
    let makeRefreshView: MakeRefreshView
    let makeLandingView: MakeLandingView
    
    public init(
        makeRefreshView: @escaping MakeRefreshView,
        makeLandingView: @escaping MakeLandingView
    ) {
        self.makeRefreshView = makeRefreshView
        self.makeLandingView = makeLandingView
    }
}

public extension SavingsAccountContentViewFactory {
    
    typealias MakeRefreshView = () -> RefreshView
    typealias MakeLandingView = (Landing) -> LandingView
}
