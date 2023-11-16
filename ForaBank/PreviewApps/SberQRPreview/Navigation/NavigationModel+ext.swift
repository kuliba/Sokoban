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

    // MARK: - Destination
    
    func resetDestination() {
        
        if navigation?.destination != nil {
            
            resetNavigation()
        }
    }
    
    func setDestination(
        to destination: Navigation.Destination
    ) {
        setNavigation(to: .destination(destination))
    }
    
    // MARK: - FullScreenCover
    
    func resetFullScreenCover() {
        
        if navigation?.fullScreenCover != nil {
            
            resetNavigation()
        }
    }
    
    func setFullScreenCover(
        to fullScreenCover: Navigation.FullScreenCover
    ) {
        setNavigation(to: .fullScreenCover(fullScreenCover))
    }
}
