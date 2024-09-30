//
//  ViewFactory.swift
//
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import SwiftUI

public struct ViewFactory<RefreshView> where RefreshView: View {

    let makeRefreshView: MakeRefreshView
    
    public init(makeRefreshView: @escaping MakeRefreshView) {
        self.makeRefreshView = makeRefreshView
    }
    
}

public extension ViewFactory {
        
    typealias MakeRefreshView = () -> RefreshView
}
