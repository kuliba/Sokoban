//
//  ContentView.swift
//  C2GPreviewApp
//
//  Created by Igor Malyarov on 12.02.2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var uinInputState: UINInputState = .init()
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Spacer()
                
                continueButton()
                sbpIcon()
            }
            
            settings
        }
    }
    
    @ViewBuilder
    private func continueButton() -> some View {
        
        if !uinInputState.isEditing {
            
            Button(action: {}) {
                
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(!uinInputState.isValid)
        }
    }
    
    private func sbpIcon() -> some View {
        
        Image(systemName: "envelope")
            .imageScale(.large)
    }
    
    private var settings: some View {
        
        VStack(spacing: 16) {
            
            Text("UIN Input State")
                .font(.headline)
            
            HStack {
                
                Text(uinInputState.isEditing ? "editing" : "noFocus")
                Divider()
                Text(uinInputState.isValid ? "valid" : "not valid")
                    .foregroundStyle(uinInputState.isValid ? .green : .red)
            }
            .fixedSize()
            
            HStack {
                
                Button("editing") { uinInputState.isEditing = true }
                Divider()
                Button("no focus") { uinInputState.isEditing = false }
            }
            .fixedSize()
            
            HStack {
                
                Button("valid") { uinInputState.isValid = true }
                    .foregroundStyle(.green)
                Divider()
                Button("invalid") { uinInputState.isValid = false }
                    .foregroundStyle(.red)
            }
            .fixedSize()
        }
        .padding()
    }
    
    private struct UINInputState {
        
        var isEditing: Bool = false
        var isValid: Bool = false
    }
}

#Preview {
    
    ContentView()
}
