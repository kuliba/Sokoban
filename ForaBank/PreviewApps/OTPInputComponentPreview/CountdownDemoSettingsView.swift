//
//  CountdownDemoSettingsView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

typealias Pickerable = RawRepresentable & CaseIterable & Identifiable & Hashable

protocol PickerDisplayable {
    
    var displayValue: String { get }
}

extension RawRepresentable where RawValue == String {
    
    var displayValue: String { self.rawValue }
}

extension RawRepresentable where RawValue == Int {
    
    var displayValue: String { self.rawValue.formatted() }
}

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
            
            pickerSection("Duration (sec)", selection: $duration)
            pickerSection("Initiate Result", selection: $initiateResult)
        }
        .listStyle(.plain)
        .overlay(alignment: .bottom, content: applyButton)
    }
    
    private func pickerSection<T: Pickerable & PickerDisplayable>(
        _ title: String,
        selection: Binding<T>
    ) -> some View where T.AllCases: RandomAccessCollection {
        
        Section(title) {
            
            Picker(title, selection: selection) {
                
                ForEach(T.allCases) {
                    
                    Text($0.displayValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var settings: CountdownDemoSettings {
        
        .init(duration: duration, initiateResult: initiateResult)
    }
    
    private func applyButton(
    ) -> some View {
        
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
        
        countdownDemoSettingsView(.fiveSuccess)
        countdownDemoSettingsView(.fiveConnectivity)
        countdownDemoSettingsView(.fiveServer)
    }
    
    private static func countdownDemoSettingsView(
        _ settings: CountdownDemoSettings
    ) -> some View {
        
        CountdownDemoSettingsView(settings: settings, apply: { _ in })
    }
}
