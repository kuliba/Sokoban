//
//  CountdownDemoSettings+ext.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

extension CountdownDemoSettings {
    
    static let fiveSuccess: Self = .init(
        duration: .five,
        initiateResult: .success
    )
    
    static let fiveConnectivity: Self = .init(
        duration: .five,
        initiateResult: .connectivity
    )
    
    static let fiveServer: Self = .init(
        duration: .five,
        initiateResult: .server
    )
}
