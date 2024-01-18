//
//  ToggleMockView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import SwiftUI

struct ToggleMockView: View {
    
    let status: Status
    var hight: CGFloat = 24
    
    var body: some View {
        
        Capsule(style: .continuous)
            .strokeBorder(color)
            .frame(width: hight * 2, height: hight)
            .overlay(alignment: alignment) {
                
                color
                    .clipShape(.circle)
                    .frame(width: hight, height: hight)
            }
    }
    
    var color: Color {
        
        switch status {
        case .active:   return .green
        case .inactive: return .black
        }
    }
    
    var alignment: Alignment {
        
        switch status {
        case .active:   return .trailing
        case .inactive: return .leading
        }
    }
}

extension ToggleMockView {
    
    enum Status {
        
        case active, inactive
    }
}

struct ToggleMockView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            toggleMockView(.active)
            toggleMockView(.inactive)
        }
    }
    
    private static func toggleMockView(
        _ status: ToggleMockView.Status,
        height: CGFloat = 24
    ) -> some View {
        
        ToggleMockView(status: status, hight: height)
    }
}
