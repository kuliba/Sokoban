//
//  ManageSubscriptionUIPreviewApp.swift
//  ManageSubscriptionUIPreview
//
//  Created by Дмитрий Савушкин on 19.07.2023.
//

import SwiftUI

@main
struct ManageSubscriptionUIPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(subscriptionViewModel: .preview)
        }
    }
}
