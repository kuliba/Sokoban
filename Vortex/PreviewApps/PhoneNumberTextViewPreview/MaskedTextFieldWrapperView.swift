//
//  MaskedTextFieldWrapperView.swift
//  PhoneNumberTextViewPreview
//
//  Created by Igor Malyarov on 09.01.2025.
//

import SwiftUI
import TextFieldUI

struct MaskedTextFieldWrapperView: View {
    
    @State private var mask: Mask = .phone
    @State private var keyboardType: KeyboardType = .number
    
    var body: some View {
        
        VStack {
            
            MaskedTextFieldView(
                placeholder: "Type \(mask.title) here",
                mask: mask.value,
                keyboardType: keyboardType.keyboardType
            )
            .id(mask)
            .id(keyboardType)
            
            Text(mask.value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
            
            maskPicker()
            keyboardPicker()
        }
        .padding(.horizontal)
    }
}

extension MaskedTextFieldWrapperView {
    
    enum Mask: String, CaseIterable {
        
        case dateShort, dateLong, phone
        
        var title: String {
            
            switch self {
            case .dateShort: return "short date"
            case .dateLong:  return "long date"
            case .phone:     return "phone number"
            }
        }
        
        var value: String {
            
            switch self {
            case .dateShort: return "__.__"
            case .dateLong:  return "__.____"
            case .phone:     return "+7(___)-___-__-__"
            }
        }
    }
    
    enum KeyboardType: String, CaseIterable {
        
        case `default`
        case number
        case decimal
        
        var keyboardType: TextFieldUI.KeyboardType {
            
            switch self {
            case .default: return .default
            case .number:  return .number
            case .decimal: return .decimal
            }
        }
    }
    
    private func maskPicker() -> some View {
        
        Picker("Select mask", selection: $mask) {
            
            ForEach(Mask.allCases, id: \.self) {
                
                Text($0.rawValue).tag($0)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private func keyboardPicker() -> some View {
        
        Picker("Select keyboard", selection: $keyboardType) {
            
            ForEach(KeyboardType.allCases, id: \.self) {
                
                Text($0.rawValue).tag($0)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    
    MaskedTextFieldWrapperView()
}
