//
//  FilterEvent.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation

public enum FilterEvent {

    case openSheet([String])
    case selectedPeriod(FilterState.Period)
    case selectedTransaction(FilterState.TransactionType)
    case selectedCategory(String)
    case selectedDates(lowerDate: Date?, upperDate: Date?)
    case clearOptions
}
