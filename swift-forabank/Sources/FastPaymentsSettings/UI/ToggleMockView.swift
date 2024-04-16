//
//  ToggleMockView.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import SwiftUI

struct ToggleMockView: View {
    
    let status: Status
    let color: Color
    let knobHeight: CGFloat = 21
    var width: CGFloat = 51
    var height: CGFloat = 31
    var padding: CGFloat = 6
    
    var body: some View {
        
        Capsule(style: .continuous)
            .strokeBorder(color)
            .frame(width: width, height: height)
            .overlay(
                Circle()
                    .fill(color)
                    .frame(width: knobHeight, height: knobHeight)
                    .padding(.horizontal, 5),
                alignment: alignment
            )
    }
    
    var alignment: Alignment {
        
        switch status {
        case .on(.enabled):   return .trailing
        case .on(.disabled):  return .trailing
        case .off(.enabled):  return .leading
        case .off(.disabled): return .leading
        }
    }
}

extension ToggleMockView {
    
    enum Status {
        
        case on(Mode)
        case off(Mode)
        
        enum Mode {
            
            case enabled, disabled
        }
    }
}

struct ToggleMockView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            toggleMockView(.on(.enabled), color: .green)
            toggleMockView(.on(.disabled), color: .gray)
            toggleMockView(.off(.enabled), color: .black)
            toggleMockView(.off(.disabled), color: .blue)
        }
    }
    
    private static func toggleMockView(
        _ status: ToggleMockView.Status,
        color: Color
    ) -> some View {
        
        ToggleMockView(status: status, color: color)
    }
}
