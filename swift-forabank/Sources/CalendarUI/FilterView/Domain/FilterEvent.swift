//
//  FilterEvent.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation

public enum FilterEvent {

    case resetPeriod(ClosedRange<Date>, [String])
    case selectedPeriod(FilterHistoryState.Period)
    case selectedTransaction(FilterHistoryState.TransactionType?)
    case selectedCategory(String)
    case selectedDates(ClosedRange<Date>?, FilterHistoryState.Period)
    case updateFilter(FilterState?)
    case clearOptions
}
