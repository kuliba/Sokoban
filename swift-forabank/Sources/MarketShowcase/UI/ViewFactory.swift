//
//  ViewFactory.swift
//
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import SwiftUI

public struct ViewFactory<RefreshView, LandingViewModel, LandingView>
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

public extension ViewFactory {
    
    typealias MakeRefreshView = () -> RefreshView
    typealias MakeLandingView = (LandingViewModel) -> LandingView
}
