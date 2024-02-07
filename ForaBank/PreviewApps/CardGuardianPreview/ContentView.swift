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
        
        NavigationView {
            NavigationLink(destination: destination()) {
                Image(systemName: "person.text.rectangle.fill")
                    .renderingMode(.original)
                    .foregroundColor(Color(.systemMint))
                    .font(.system(size: 120))
            }
        }
    }
    
    private func destination() -> some View {
        
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("Aктивна, на главном")
                    .lineLimit(2)
                Spacer()
                ProductProfileView.cardUnblokedOnMain
            }
            HStack {
                Text("Заблокирована (можно разблокировать)")
                    .lineLimit(2)
                Spacer()
                ProductProfileView.cardBlockedHideOnMain
            }
            HStack {
                Text("Заблокирована (нельзя разблокировать)")
                    .lineLimit(2)
                Spacer()
                ProductProfileView.cardBlockedUnlockNotAvailable
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
