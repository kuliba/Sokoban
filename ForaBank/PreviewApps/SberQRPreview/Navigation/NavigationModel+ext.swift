//
//  NavigationModel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//


// MARK: - Convenience Navigation API

extension NavigationModel {
    
    // MARK: - Reset
    
    func resetNavigation() {
        
        setNavigation(to: nil)
    }
    
    // MARK: - Alert
    
    func resetAlert() {
        
        if navigation?.destination != nil {
            
            resetNavigation()
        }
    }
    
    func setAlert(
        to alert: Navigation.Alert
    ) {
        setNavigation(to: .alert(alert))
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
    
    // MARK: - Sheet
    
    func resetSheet() {
        
        if navigation?.sheet != nil {
            
            resetNavigation()
        }
    }
    
    func setSheet(
        to sheet: Navigation.Sheet
    ) {
        setNavigation(to: .sheet(sheet))
    }
}
