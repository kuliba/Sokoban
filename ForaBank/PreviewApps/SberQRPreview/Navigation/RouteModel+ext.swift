//
//  RouteModel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//


// MARK: - Convenience Navigation API

extension RouteModel {
    
    // MARK: - Alert
    
    func resetAlert() {
        
        resetModel()
    }
    
    func setAlert(
        to alert: Route.Modal.Alert
    ) {
        setModal(to: .alert(alert))
    }
    
    // MARK: - FullScreenCover
    
    func resetFullScreenCover() {
        
        resetModel()
    }
    
    func setFullScreenCover(
        to fullScreenCover: Route.Modal.FullScreenCover
    ) {
        setModal(to: .fullScreenCover(fullScreenCover))
    }
    
    // MARK: - Sheet
    
    func resetSheet() {
        
        resetModel()
    }
    
    func setSheet(
        to sheet: Route.Modal.Sheet
    ) {
        setModal(to: .sheet(sheet))
    }
}
