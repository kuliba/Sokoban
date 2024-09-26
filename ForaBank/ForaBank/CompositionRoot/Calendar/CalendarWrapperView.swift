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
 
extension CalendarWrapperView {
    
    enum Event {
        
        case clear
        case dismiss
    }
}

struct CalendarWrapperView: View {
    
    @State var state: CalendarState
    let event: (Event) -> Void
    let config: CalendarConfig
    let apply: (Date?, Date?) -> Void
    
    var body: some View {
        
        VStack(spacing: 16) { //FIX: remove double VStack
            
            VStack(spacing: 24) {
                
                ZStack {
                    
                    calendarView()
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
                                action: { event(.dismiss) }
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
                                    apply(
                                        state.range?.lowerDate,
                                        state.range?.upperDate?.isToday() ?? false ? Date() : state.range?.upperDate?.endOfDay
                                    )
                                }
                            )
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
    
    func calendarView() -> some View {
        
        CalendarView(
            state: state,
            event: { event in
                switch event {
                case let .selectedDate(date):
                    self.state = .init(
                        date: state.date,
                        range: updateRange(range: state.range, date: date),
                        monthsData: state.monthsData,
                        periods: state.periods
                    )
                case let .selectPeriod(period, lowerDate, upperDate):
                    state.range = .init(startDate: lowerDate, endDate: upperDate)
                    state.selectPeriod = period
                        
                case .selectCustomPeriod:
                    self.state = .init(
                        date: state.date,
                        range: .init(startDate: nil, endDate: nil),
                        monthsData: state.monthsData,
                        selectPeriod: nil,
                        periods: state.periods
                    )
                    break
                }
            },
            config: config
        )
    }
    
    private func updateRange(range: MDateRange?, date: Date) -> MDateRange {
        guard let range = range else {
            return .init(startDate: date, endDate: nil)
        }
        
        if let lowerDate = range.lowerDate, let upperDate = range.upperDate {
            return .init(startDate: date, endDate: nil)
            
        } else if let lowerDate = range.lowerDate {
            
            let oneMonthInSeconds: TimeInterval = 2678400
            let upperRange = lowerDate...lowerDate.addingTimeInterval(oneMonthInSeconds)
            let lowRange = lowerDate.addingTimeInterval(-oneMonthInSeconds)...lowerDate
            
            if upperRange.contains(date) || lowRange.contains(date) {
                return lowerDate > date ?
                    .init(startDate: date, endDate: lowerDate) :
                    .init(startDate: lowerDate, endDate: date)
            } else {
                return .init(startDate: lowerDate, endDate: nil)
            }
        }
        
        return .init(startDate: date, endDate: nil)
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
