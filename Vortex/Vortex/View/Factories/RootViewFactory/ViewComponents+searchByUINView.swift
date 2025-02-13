//
//  ViewComponents+searchByUINView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    func searchByUINView() -> some View {
        
        VStack(spacing: 16) {
            
            Text("TBD: Search by UIN")
                .font(.headline)
            
            Button("Select 0...90...9") { }
            Button("Select 1...01...0") { }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.bordered)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
