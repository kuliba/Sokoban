//
//  OTPFieldDemoSettingsView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

extension OTPFieldDemoSettings: PickerDisplayable {}

struct OTPFieldDemoSettingsView: View {
    
    @State var otpSettings: OTPFieldDemoSettings
    let apply: (OTPFieldDemoSettings) -> Void
    
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

struct OTPFieldDemoSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OTPFieldDemoSettingsView(
            otpSettings: .success,
            apply: { _ in }
        )
    }
}
