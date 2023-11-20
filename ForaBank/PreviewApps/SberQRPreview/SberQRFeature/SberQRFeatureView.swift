//
//  SberQRFeatureView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2023.
//

import SwiftUI

struct SberQRFeatureView: View {
    
    let url: URL
    let dismiss: () -> Void
    
    @State private var selection: Selection?
    
    var body: some View {
        
        SberQRPaymentView(
            url: url,
            dismiss: dismiss
        ) { url, completion in
            
            selection = .init(url: url, completion: completion)
        }
        .sheet(item: $selection) { selection in
            
            NavigationView {
                
                TextPickerView(
                    commit: { text in
                        
                        self.selection = nil
                        selection.completion(text)
                    }
                )
                .navigationTitle("Select")
            }
        }
    }
    
    private struct Selection: Hashable, Identifiable {
        
        let id = UUID()
        let url: URL
        let completion: (String?) -> Void
        
        static func == (lhs: Selection, rhs: Selection) -> Bool {
            
            lhs.id == rhs.id && lhs.url == rhs.url
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
            hasher.combine(url)
        }
    }
}

#Preview {
    SberQRFeatureView(
        url: .init(string: "https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822")!,
        dismiss: {}
    )
}
