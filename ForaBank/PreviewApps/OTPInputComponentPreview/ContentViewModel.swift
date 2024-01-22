//
//  ContentViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation
import OTPInputComponent

final class ContentViewModel: ObservableObject {
    
    typealias MakeTimedOTPInputViewModel = (CountdownDemoSettings, OTPFieldDemoSettings) -> TimedOTPInputViewModel
   typealias ConfirmWithOTPSettings = OTPFieldDemoSettings

    @Published private(set) var confirmWithOTPSettings: ConfirmWithOTPSettings = .connectivity
    @Published private(set) var countdownDemoSettings: CountdownDemoSettings = .shortSuccess
    @Published private(set) var otpFieldDemoSettings: OTPFieldDemoSettings = .success
    
    @Published private(set) var fullScreenCover: FullScreenCover?
    @Published private(set) var isShowingSpinner = false
    @Published private(set) var alert: String?
    @Published private(set) var informer: String?
    
    private let makeTimedOTPInputViewModel: MakeTimedOTPInputViewModel
    
    init(makeTimedOTPInputViewModel: @escaping MakeTimedOTPInputViewModel) {

        self.makeTimedOTPInputViewModel = makeTimedOTPInputViewModel
    }
}

extension ContentViewModel {
    
    func confirmWithOTP() {
        
        isShowingSpinner = true
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2
        ) { [weak self] in
                
                guard let self else { return }
                
                isShowingSpinner = false
                
                switch confirmWithOTPSettings {
                case .connectivity:
                    informer = "Ошибка изменения настроек СБП.\nПопробуйте позже."
                    
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 1,
                        execute: { [weak self] in self?.informer = nil }
                    )
                    
                case .server:
                    alert = "Server Error Failure"
                    
                case .success:
                    fullScreenCover = .confirmWithOTP
                }
            }
    }
    
    func showConfirmWithOTPSettings() {
        
        fullScreenCover = .settings(.confirmWithOTPSettings)
    }
    
    func showCountdownOptions() {
        
        fullScreenCover = .settings(.countdownDemoSettings)
    }
    
    func showOTPFieldDemoSettings() {
        
        fullScreenCover = .settings(.otpFieldDemoSettings)
    }
    
    func resetFullScreenCover() {
        
        fullScreenCover = nil
    }
}

extension ContentViewModel {
    
    func updateConfirmWithOTPSettings(
        _ settings: ConfirmWithOTPSettings
    ) {
        self.confirmWithOTPSettings = settings
        self.fullScreenCover = nil
    }
    
    func updateOTPSettings(
        _ otpFieldDemoSettings: OTPFieldDemoSettings
    ) {
        self.otpFieldDemoSettings = otpFieldDemoSettings
        self.fullScreenCover = nil
    }
    
    func updateCountdownDemoSettings(
        _ settings: CountdownDemoSettings
    ) {
        self.countdownDemoSettings = settings
        self.fullScreenCover = nil
    }
}

extension ContentViewModel {
    
    enum FullScreenCover: Identifiable {

        case confirmWithOTP
        case settings(Settings)

        var id: Int {
            
            switch self {
            case .confirmWithOTP:
                return "confirmWithOTP".hashValue
                
            case let .settings(settings):
                return settings.hashValue
            }
        }
        
        enum Settings: Identifiable {
            
            case confirmWithOTPSettings
            case countdownDemoSettings
            case otpFieldDemoSettings

            var id: Int { hashValue }
        }
    }
}
