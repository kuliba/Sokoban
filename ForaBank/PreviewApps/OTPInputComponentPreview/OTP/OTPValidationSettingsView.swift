//
//  OTPValidationSettingsView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

struct OTPValidationSettingsView: View {
    
    @State var otpSettings: OTPSettings
    let apply: (OTPSettings) -> Void
    
    var body: some View {
        
        List {
            
            pickerSection(
                "OTP Validation Result",
                selection: $otpSettings)
        }
        .listStyle(.plain)
        .overlay(alignment: .bottom, content: applyButton)
    }
    
    private func pickerSection<T: Pickerable>(
        _ title: String,
        selection: Binding<T>
    ) -> some View where T.RawValue == String, T.AllCases: RandomAccessCollection {
        
        Section(title) {
            
            Picker(title, selection: selection) {
                
                ForEach(T.allCases) {
                    
                    Text($0.rawValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func applyButton() -> some View {
        
        Button {
            apply(otpSettings)
        } label: {
            Text("Apply")
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
    }
}

struct OTPValidationOptionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OTPValidationSettingsView(
            otpSettings: .success,
            apply: { _ in }
        )
    }
}
