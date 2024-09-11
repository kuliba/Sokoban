//
//  CalendarWrapperView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 22.07.2024.
//

import Foundation
import SwiftUI
import CalendarUI
import SharedConfigs

struct CalendarWrapperView: View {
    
//    @ObservedObject var selectedRange: MDateRange
    @State var state: CalendarState
//    let closeAction: () -> Void
//    let applyAction: (MDateRange) -> Void
//    let endDateCalendar: Date?
    let config: CalendarConfig
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            ZStack {
                
                HStack {
                    
                    Button(action: {} /*closeAction*/, label: {
                        Image.ic24ChevronLeft
                            .foregroundColor(.textSecondary)
                    })
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                config.title.text(withConfig: config.titleConfig)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 24) {
                
                ZStack {
                    
                    calendarView(endDate: Date()/*endDateCalendar*/)
                        .padding(10)
                    
                    VStack {
                        
                        Spacer()
                        
                        HStack {
                            
                            simpleButtonView(
                                config: .init(
                                    title: "Закрыть",
                                    titleConfig: .init(
                                        textFont: .textH3Sb18240(),
                                        textColor: .textSecondary
                                    ),
                                    background: .buttonSecondary
                                ),
                                action: {}/*closeAction*/
                            )
                            
                            simpleButtonView(
                                config: .init(
                                    title: "Показать",
                                    titleConfig: .init(
                                        textFont: .textH3Sb18240(),
                                        textColor: .white
                                    ),
                                    background: .buttonPrimary
                                ),
                                action: {
//                                    applyAction(state.range?.rangeSelected)
                                }
                            )
//                            .allowsHitTesting(selectedRange.rangeSelected == true ? false : true)
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 30)
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}

private extension CalendarWrapperView {
    
    func calendarView(endDate: Date?) -> some View {
        
        CalendarView(
            state: state,
            event: { _ in },
            config: config
        )
    }
    
    func simpleButtonView(
        config: SimpleButtonConfig,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            config.title.text(withConfig: config.titleConfig)
                .frame(minWidth: 100, idealWidth: 100, maxWidth: .infinity, minHeight: 56, idealHeight: 56, maxHeight: 56, alignment: .center)
                .padding(.horizontal, 16)
                .background(config.background)
                .font(.system(size: 18))
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

extension CalendarWrapperView {
    
    struct SimpleButtonConfig {
        
        let title: String
        let titleConfig: TextConfig
        let background: Color
    }
}

struct RangeSelector {
    
    let date: Date
    let isCurrentMonth: Bool
    let selectedDate: Date?
    var selectedRange: MDateRange?
    let selectDate: (Date) -> Void
    
    func dayLabel() -> AnyView {
        
        Text(getStringFromDay(format: "d"))
            .font(.system(size: 15))
            .foregroundColor(isSelected() ? .white : .black)
            .opacity(isFuture() ? 0.2 : 1)
            .erased()
    }
}

extension RangeSelector {
    
    func onSelection() {
        
        if !isFuture() {
            
            if let lowerDate = selectedRange?.lowerDate,
               lowerDate.isBetweenStartDate(date.addingTimeInterval(2629800), endDateInclusive: date.addingTimeInterval(-2629800))
            {
                selectDate(date)
            } else if selectedRange?.lowerDate == nil{
                selectDate(date)
            } else if selectedRange?.upperDate != nil {
                selectDate(date)
            }
        }
    }
    
    func isFuture() -> Bool {
        date.isLater(.day, than: Date())
    }
    
    func getStringFromDay(format: String) -> String {
    
        MDateFormatter.getString(from: date, format: format)
    }
    
    func isSelected() -> Bool {
        date.isSame(.day, as: selectedDate) || isBeginningOfRange() || isEndOfRange()
    }
    
    func isBeginningOfRange() -> Bool {
        date.isSame(.day, as: selectedRange?.getRange()?.lowerBound)
        
    }
    
    func isEndOfRange() -> Bool {
        date.isSame(.day, as: selectedRange?.getRange()?.upperBound)
    }
    
    func isWithinRange() -> Bool {
        
        selectedRange?.isRangeCompleted() == true && selectedRange?.contains(date) == true
    }
    
    func isRangeCompleted() -> Bool { 
        selectedRange?.upperDate != nil
    }
    
    func contains(_ date: Date) -> Bool { 
        selectedRange?.getRange()?.contains(date) == true
    }

}
