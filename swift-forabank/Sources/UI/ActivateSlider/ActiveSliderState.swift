//
//  ActiveSliderState.swift
//  
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import Foundation

public struct ActiveSliderState: Equatable {
        
    var event: ActivateSlider.Event?
    
    public init(
        event: ActivateSlider.Event? = nil
    ) {
        self.event = event
    }
}
