//
//  NavigationModel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//


// MARK: - Convenience Navigation API

extension NavigationModel {
    
    func resetNavigation() {
        
        setNavigation(to: nil)
    }
    
    func setFullScreenCover(
        to fullScreenCover: Navigation.FullScreenCover
    ) {
        setNavigation(to: .fullScreenCover(fullScreenCover))
    }
}
