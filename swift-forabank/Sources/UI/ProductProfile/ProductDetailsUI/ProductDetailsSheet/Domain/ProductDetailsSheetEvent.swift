//
//  ProductDetailsSheetEvent.swift
//
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import Foundation

public enum ProductDetailsSheetEvent: Equatable {
    
    case appear
    case buttonTapped(SheetButtonEvent)
}
