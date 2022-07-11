//
//  RootViewModel+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 06.07.2022.
//

import Foundation

extension RootViewModel.RootActions {
    
    static let emptyMock = RootViewModel.RootActions(dismissCover: {}, spinner: .init(show: {}, hide: {}), switchTab: { _ in })
}
