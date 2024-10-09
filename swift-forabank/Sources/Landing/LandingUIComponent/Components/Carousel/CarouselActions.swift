//
//  CarouselActions.swift
//  
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import Foundation

public struct CarouselActions {
    
    let openUrl: (String) -> Void
    let goToMain: () -> Void
    
    public init(
        openUrl: @escaping (String) -> Void,
        goToMain: @escaping () -> Void
    ) {
        self.openUrl = openUrl
        self.goToMain = goToMain
    }
}
