//
//  CardGuardianPreviewApp.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI

@main
struct CardGuardianPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            
            TabView {
                ContentView(
                    buttons: .preview,
                    topUpCardButtons: .previewRegular,
                    accountInfoPanelButtons: .previewRegular,
                    accountDetails: [],
                    cardDetails: .cardItemsWithInfo, 
                    sheetButtons: .previewRegular
                )
                .background(.cyan)
                .tabItem {
                    Label("1", systemImage: "list.dash")
                }
                
                ContentView(
                    buttons: .previewBlockHide,
                    topUpCardButtons: .previewAdditionalOther,
                    accountInfoPanelButtons: .previewAdditionalOther,
                    accountDetails: .accountItems,
                    cardDetails: .cardItems,
                    sheetButtons: .previewRegular
                )
                .tabItem {
                    Label("2", systemImage: "square.and.pencil")
                }
                
                ContentView(
                    buttons: .previewBlockUnlockNotAvailable,
                    topUpCardButtons: .previewAdditionalSelfNotOwner,
                    accountInfoPanelButtons: .previewAdditionalSelfNotOwner,
                    accountDetails: .accountItems,
                    cardDetails: .cardItems,
                    sheetButtons: .previewRegular
                )
                .tabItem {
                    Label("3", systemImage: "sparkles")
                }
            }
        }
    }
}
