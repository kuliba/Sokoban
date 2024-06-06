//
//  CalendarViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation
import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    
    @Published var date: Date?
    @Published var range: MDateRange?
    
    init(
        _ selectedDate: Binding<Date?>?,
        _ selectedRange: Binding<MDateRange?>?
    ) {
        self._date = .init(wrappedValue: selectedDate?.wrappedValue)
        self._range = .init(wrappedValue: selectedRange?.wrappedValue)
    }
    
    func updateDateBinding() {
        
    }
    
    func updateDateRangeBinding() {
        
    }
}
