//
//  CalendarViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation
import SwiftUI

public class CalendarViewModel: ObservableObject {
    
    @Published public var date: Date?
    @Published public var range: MDateRange?
    
    public init(
        _ selectedDate: Date?,
        _ selectedRange: MDateRange?
    ) {
        self.date = selectedDate
        self.range = selectedRange
    }
}
