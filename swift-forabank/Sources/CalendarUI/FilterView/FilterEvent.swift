//
//  FilterEvent.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation

public enum FilterEvent {

    case openSheet([String])
    case selectedPeriod(FilterHistoryState.Period)
    case selectedTransaction(FilterHistoryState.TransactionType?)
    case selectedCategory(Set<String>)
    case selectedDates(lowerDate: Date?, upperDate: Date?)
    case updateFilter(FilterState?)
    case clearOptions
}
