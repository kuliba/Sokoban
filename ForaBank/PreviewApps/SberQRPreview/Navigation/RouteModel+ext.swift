//
//  RouteModel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//


// MARK: - Convenience Navigation API

extension RouteModel {
    
    // MARK: - Reset
    
    func resetRoute() {
        
        setRoute(to: nil)
    }
    
    // MARK: - Alert
    
    func resetAlert() {
        
        if route?.destination != nil {
            
            resetRoute()
        }
    }
    
    func setAlert(
        to alert: Route.Alert
    ) {
        setRoute(to: .alert(alert))
    }
    
    // MARK: - Destination
    
    func resetDestination() {
        
        if route?.destination != nil {
            
            resetRoute()
        }
    }
    
    func setDestination(
        to destination: Route.Destination
    ) {
        setRoute(to: .destination(destination))
    }
    
    // MARK: - FullScreenCover
    
    func resetFullScreenCover() {
        
        if route?.fullScreenCover != nil {
            
            resetRoute()
        }
    }
    
    func setFullScreenCover(
        to fullScreenCover: Route.FullScreenCover
    ) {
        setRoute(to: .fullScreenCover(fullScreenCover))
    }
    
    // MARK: - Sheet
    
    func resetSheet() {
        
        if route?.sheet != nil {
            
            resetRoute()
        }
    }
    
    func setSheet(
        to sheet: Route.Sheet
    ) {
        setRoute(to: .sheet(sheet))
    }
}
