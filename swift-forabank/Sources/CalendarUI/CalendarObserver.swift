//
//  CalendarObserver.swift
//  
//
//  Created by Дмитрий Савушкин on 20.08.2024.
//

import Foundation
import SwiftUI

class CalendarObserver: ObservableObject {
    
    @Published var date: Date? { didSet { updateDateBinding() }}
    @Published var range: MDateRange? { didSet { updateDateRangeBinding() }}
    private var p_date: Binding<Date?>?
    private var p_range: Binding<MDateRange?>?
    
    
    init(_ selectedDate: Binding<Date?>?, _ selectedRange: Binding<MDateRange?>?) {
        self._date = .init(wrappedValue: selectedDate?.wrappedValue)
        self._range = .init(wrappedValue: selectedRange?.wrappedValue)
        
        self.p_date = selectedDate
        self.p_range = selectedRange
    }
}

private extension CalendarObserver {
    
    func updateDateBinding() { p_date?.wrappedValue = date }
    func updateDateRangeBinding() { p_range?.wrappedValue = range }
}
