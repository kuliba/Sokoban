//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        NavigationStack {
            
            UserAccountView(viewModel: .preview(
                route: .init(),
                getContractConsentAndDefault: { completion in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        
                        completion(.inactive())
                    }
                }
            ))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
