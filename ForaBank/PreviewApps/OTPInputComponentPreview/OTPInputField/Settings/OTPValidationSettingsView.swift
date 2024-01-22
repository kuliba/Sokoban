//
//  OTPValidationSettingsView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

extension OTPValidationSettings: PickerDisplayable {}

struct OTPValidationSettingsView: View {
    
    @State var otpSettings: OTPValidationSettings
    let apply: (OTPValidationSettings) -> Void
    
    var body: some View {
        
        List {
            
            PickerSection(
                title: "OTP Validation Result",
                selection: $otpSettings)
        }
        .listStyle(.plain)
        .overlay(alignment: .bottom, content: applyButton)
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
