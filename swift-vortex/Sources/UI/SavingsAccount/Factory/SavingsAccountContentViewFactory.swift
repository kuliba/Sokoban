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
    
    let refreshView: RefreshView
    let makeLandingView: MakeLandingView
    
    public init(
        refreshView: RefreshView,
        makeLandingView: @escaping MakeLandingView
    ) {
        self.refreshView = refreshView
        self.makeLandingView = makeLandingView
    }
}

public extension SavingsAccountContentViewFactory {
    
    typealias MakeLandingView = (Landing) -> LandingView
}
