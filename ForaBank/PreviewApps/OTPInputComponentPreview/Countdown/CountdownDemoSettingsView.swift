//
//  CountdownDemoSettingsView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

extension CountdownDemoSettings.Duration: PickerDisplayable {}
extension CountdownDemoSettings.InitiateResult: PickerDisplayable {}

struct CountdownDemoSettingsView: View {
    
    typealias Apply = (CountdownDemoSettings) -> Void
    
    @State private var duration: CountdownDemoSettings.Duration
    @State private var initiateResult: CountdownDemoSettings.InitiateResult
    
    private let apply: Apply
    
    init(
        settings: CountdownDemoSettings,
        apply: @escaping Apply
    ) {
        self.apply = apply
        self._duration = .init(initialValue: settings.duration)
        self._initiateResult = .init(initialValue: settings.initiateResult)
    }
    
    var body: some View {
        
        List {
            
            PickerSection(
                title: "Duration (sec)",
                selection: $duration
            )
            PickerSection(
                title: "Initiate Result",
                selection: $initiateResult
            )
        }
        .listStyle(.plain)
        .overlay(alignment: .bottom, content: applyButton)
    }
    
    var settings: CountdownDemoSettings {
        
        .init(duration: duration, initiateResult: initiateResult)
    }
    
    private func applyButton() -> some View {
        
        Button {
            apply(settings)
        } label: {
            Text("Apply")
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
    }
}

struct CountdownDemoSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        countdownDemoSettingsView(.shortSuccess)
        countdownDemoSettingsView(.shortConnectivity)
        countdownDemoSettingsView(.shortServer)
    }
    
    private static func countdownDemoSettingsView(
        _ settings: CountdownDemoSettings
    ) -> some View {
        
        CountdownDemoSettingsView(settings: settings, apply: { _ in })
    }
}
