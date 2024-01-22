//
//  ContentViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation
import OTPInputComponent

typealias ConfirmWithOTPSettings = DemoSettingsResult

final class ContentViewModel: ObservableObject {
    
    @Published private(set) var confirmWithOTPSettings: ConfirmWithOTPSettings = .success
    @Published private(set) var countdownDemoSettings: CountdownDemoSettings = .shortSuccess
    @Published private(set) var otpFieldDemoSettings: DemoSettingsResult = .success
    
    @Published private(set) var modal: Modal?
}

extension ContentViewModel {
    
    func confirmWithOTP() {
        
        modal = .spinner
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1
        ) { [weak self] in
            
            guard let self else { return }
            
            resetModal()
            
            switch confirmWithOTPSettings {
            case .connectivity:
                modal = .informer(.init(message: "Ошибка изменения настроек СБП.\nПопробуйте позже."))
                
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1,
                    execute: { [weak self] in self?.resetModal() }
                )
                
            case .server:
                modal = .alert(.init(message: "Server Error Failure"))
                
            case .success:
                modal = .fullScreenCover(.confirmWithOTP)
            }
        }
    }
    
    func resetModal() {
        
        modal = nil
    }
}

// MARK: - Settings Update

extension ContentViewModel {
    
    func updateConfirmWithOTPSettings(
        _ settings: ConfirmWithOTPSettings
    ) {
        self.confirmWithOTPSettings = settings
    }
    
    func updateOTPFieldDemoSettings(
        _ otpFieldDemoSettings: DemoSettingsResult
    ) {
        self.otpFieldDemoSettings = otpFieldDemoSettings
    }
    
    func updateCountdownDemoSettings(
        _ settings: CountdownDemoSettings
    ) {
        self.countdownDemoSettings = settings
    }
    
    func updateCountdownDemoDuration(
        _ duration: CountdownDemoSettings.Duration
    ) {
        self.countdownDemoSettings.duration = duration
    }
    
    func updateCountdownDemoInitiateResult(
        _ initiateResult: CountdownDemoSettings.InitiateResult
    ) {
        self.countdownDemoSettings.initiateResult = initiateResult
    }
}

// MARK: - Modal

extension ContentViewModel {
    
    enum Modal {
        
        case alert(Alert)
        case fullScreenCover(FullScreenCover)
        case informer(Informer)
        case spinner
        
        struct Alert: Identifiable {
            
            let message: String
            
            var id: String { message }
        }
        
        enum FullScreenCover: Identifiable {
            
            case confirmWithOTP
            
            var id: Self { self }
        }
        
        struct Informer: Identifiable {
            
            let message: String
            
            var id: String { message }
        }
    }
}
