//
//  CountdownDemoSettings+ext.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

extension CountdownDemoSettings {
    
    static let shortSuccess: Self = .init(
        duration: .short,
        initiateResult: .success
    )
    
    static let shortConnectivity: Self = .init(
        duration: .short,
        initiateResult: .connectivity
    )
    
    static let shortServer: Self = .init(
        duration: .short,
        initiateResult: .server
    )
}
