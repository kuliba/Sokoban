//
//  DetailsEvent.swift
//  
//
//  Created by Andryusina Nataly on 07.03.2024.
//

import Tagged

public enum DetailsEvent: Equatable {
    
    case appear
    case itemTapped(ItemEvent)
}
