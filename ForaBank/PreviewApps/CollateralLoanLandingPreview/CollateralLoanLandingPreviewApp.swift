//
//  CollateralLoanLandingApp.swift
//  CollateralLoanLandingPreview
//
//  Created by Valentin Ozerov on 05.11.2024.
//

import SwiftUI

@main
struct CollateralLoanLandingApp: App {

    let flow = ContentViewModelComposer().compose()
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: flow)
        }
    }
}
