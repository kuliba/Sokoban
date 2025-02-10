//
//  Splash.swift
//  
//
//  Created by Igor Malyarov on 27.01.2025.
//

public struct Splash {
    
    public var data: SplashScreenState
    public let config: SplashScreenDynamicConfig
    
    public init(
        data: SplashScreenState,
        config: SplashScreenDynamicConfig
    ) {
        self.data = data
        self.config = config
    }
}
