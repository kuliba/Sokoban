//
//  ContentView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianModule
import ProductProfile

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            
            ProductProfileView.cardUnblokedOnMain
                .tabItem {
                    Label("1", systemImage: "lock.open")
                }
            
            ProductProfileView.cardBlockedHideOnMain
                .tabItem {
                    Label("2", systemImage: "lock")
                }
        }
    }
}

#Preview {
    ContentView()
}
