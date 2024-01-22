//
//  CountdownView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct CountdownView: View {
    
    @ObservedObject private var viewModel: CountdownViewModel
    private let composer: CountdownComposer
    
    init(settings: CountdownDemoSettings) {
        
        let composer = CountdownComposer.default(settings)
        let viewModel = composer.makeViewModel(
            duration: settings.duration.rawValue
        )
        self._viewModel = .init(wrappedValue: viewModel)
        self.composer = composer
    }
    
    var body: some View {
        
        switch viewModel.state {
        case .completed:
            Button("resend") { viewModel.event(.prepare) }
                .buttonStyle(.bordered)
            
        case let .failure(countdownFailure):
            Text("Alert: \(String(describing: countdownFailure))")
                .foregroundStyle(.red)
            
        case let .running(remaining: remaining):
            Text(remainingTime(remaining))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            
        case let .starting(duration):
            Text(remainingTime(duration))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
    
    func remainingTime(_ remaining: Int) -> String {
        
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CountdownView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CountdownView(settings: .shortSuccess)
    }
}

extension CountdownComposer {
    
    static func `default`(
        _ settings: CountdownDemoSettings
    ) -> CountdownComposer {
        
        .init(
            activate: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(settings.initiateResult.result)
                }
            }
        )
    }
}
