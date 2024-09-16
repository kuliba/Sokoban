//
//  DayView.swift
//
//
//  Created by Дмитрий Савушкин on 17.05.2024.
//

import SwiftUI
import Foundation
import SharedConfigs

public struct DayConfig {

    let selectedColor: Color
    let todayBackground: Color
    let todayForeground: Color
    
    public init(
        selectedColor: Color,
        todayBackground: Color,
        todayForeground: Color
    ) {
        self.selectedColor = selectedColor
        self.todayBackground = todayBackground
        self.todayForeground = todayForeground
    }
}

public struct DayView: View {
    
    public typealias Config = DayConfig
    
    var date: Date
    var isCurrentMonth: Bool
    var selectedDate: Date?
    var selectedRange: MDateRange?
    var selectDate: (Date) -> Void
    let config: Config
    
    public init(
        date: Date,
        isCurrentMonth: Bool,
        config: Config,
        selectedDate: Date? = nil,
        selectedRange: MDateRange? = nil,
        selectDate: @escaping (Date) -> Void
    ) {
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.config = config
        self.selectedDate = selectedDate
        self.selectedRange = selectedRange
        self.selectDate = selectDate
    }
    
    public var body: some View {
        
        Group {
            
            if isCurrentMonth {
                
                bodyForCurrentMonth()
            } else {
                bodyForOtherMonth()
            }
            
        }
    }
}

// MARK: - Default View Implementation
public extension DayView {
    
    func content() -> AnyView {
        
        defaultContent()
            .erased()
    }
    
    func dayLabel() -> AnyView {
        
        defaultDayLabel()
            .erased()
    }
    
    func selectionView() -> AnyView {
        
        if isToday() {

            return todayView().erased()

        } else{
         
            return defaultSelectionView().erased()
        }
    }
    
    func rangeSelectionView() -> AnyView {
        defaultRangeSelectionView().erased()
    }
}

private extension DayView {
    
    func defaultContent() -> some View {
     
        ZStack {
            
            selectionView()
            
            rangeSelectionView()
            
            dayLabel()
            
        }
    }
    
    func defaultDayLabel() -> some View {
        
        if isToday() {
            
            Text(getStringFromDay(format: "d"))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected() ? .selectedLabel : config.todayForeground)
            
        } else {
            
            Text(getStringFromDay(format: "d"))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected() ? .selectedLabel : .onBackgroundPrimary)
        }
    }
    
    func defaultSelectionView() -> some View {
        
        Circle()
            .fill(config.selectedColor)
            .frame(width: 32, height: 32, alignment: .center)
            .transition(.asymmetric(insertion: .scale(scale: 0.52).combined(with: .opacity), removal: .opacity))
            .active(if: isSelected())
    }
    
    func todayView() -> some View {
        
        Circle()
            .fill(isSelected() ? Color.black : config.todayBackground)
            .frame(width: 32, height: 32, alignment: .center)
            .transition(.asymmetric(insertion: .scale(scale: 0.52).combined(with: .opacity), removal: .opacity))
        
    }
    
    func defaultRangeSelectionView() -> some View {
        
        RoundedRectangle(corners: rangeSelectionViewCorners)
            .fill(Color.gray.opacity(0.1))
            .transition(.opacity)
            .active(if: isWithinRange())
            .frame(height: 32, alignment: .center)
    }
}

private extension DayView {
    
    var rangeSelectionViewCorners: RoundedRectangle.Corner {
        
        if isBeginningOfRange() {
            return [.topLeft, .bottomLeft]
        }
        
        if date.getWeekday() == .monday, isEndOfRange() {
            return [.topLeft, .bottomLeft, .topRight, .bottomRight]
        }
        
        if date.getWeekday() == .monday {
            return [.topLeft, .bottomLeft]
        }
        
        if date.getWeekday() == .sunday {
            return [.topRight, .bottomRight]
        }
        
        if date == date.endOfMonth() {
            return [.topRight, .bottomRight]
        }
        
        if isEndOfRange() {
            return [.topRight, .bottomRight]
        }

        return []
    }
}

// MARK: - Default Logic Implementation
public extension DayView {
    
    func onAppear() {}
    
    func onSelection() {
        
        if !isFuture() {
            
            selectDate(date)
        }
    }
}

// MARK: - Helpers

// MARK: Text Formatting
public extension DayView {
    /// Returns a string of the selected format for the date.
    func getStringFromDay(format: String) -> String {
    
        MDateFormatter.getString(from: date, format: format)
    }
}

// MARK: Date Helpers
public extension DayView {
    
    func isPast() -> Bool {
        date.isBefore(.day, than: .now)
    }
    
    func isToday() -> Bool { 
        date.isSame(.day, as: .now)
    }
    
    func isFuture() -> Bool {
        date.isLater(.day, than: .now)
    }
}

// MARK: Day Selection Helpers
public extension DayView {
    func isSelected() -> Bool {
        date.isSame(.day, as: selectedDate) || isBeginningOfRange() || isEndOfRange()
    }
}

// MARK: Range Selection Helpers
public extension DayView {
    
    func isBeginningOfRange() -> Bool {
        date.isSame(.day, as: selectedRange?.getRange()?.lowerBound)
        
    }
    
    func isEndOfRange() -> Bool {
        date.isSame(.day, as: selectedRange?.getRange()?.upperBound)
    }
    
    func isWithinRange() -> Bool {
        
        if selectedRange?.isRangeCompleted() == true {
          
            if let range = selectedRange?.getRange() {
                
                let upperDate = range.upperBound
                let lowerDate = range.lowerBound
                
                let range = lowerDate...upperDate
                
                if range.contains(date) {
                
                 return true
                }
            }
        }
        
        return false
    }
}

private extension DayView {
    
    func bodyForCurrentMonth() -> some View {
      
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1.0, contentMode: .fit)
            .onAppear(perform: onAppear)
            .onTapGesture(perform: onSelection)
            .opacity(isFuture() ? 0.2 : 1)
            
    }
    
    func bodyForOtherMonth() -> some View {
        Rectangle().fill(Color.clear)
    }
    
    func lastDayOfMonth(for date: Date) -> String {
        let calendar = Calendar.current
        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 0, to: date) else {
            fatalError("Unable to find the start of the next month.")
        }
        
        var components = DateComponents()
        components.second = -1  // Subtract 1 second to go back to the end of the current month
        
        guard let endOfMonth = calendar.date(byAdding: components, to: startOfNextMonth) else {
            fatalError("Unable to calculate the end of the month.")
        }
        
        return DateFormatter.shortDate.string(from: endOfMonth)
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
