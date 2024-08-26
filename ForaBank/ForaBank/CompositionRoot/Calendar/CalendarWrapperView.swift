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
    
    @ObservedObject var selectedRange: MDateRange
    let closeAction: () -> Void
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            ZStack {
                
                HStack {
                    
                    Button(action: closeAction, label: {
                        Image.ic24ArrowLeft
                            .foregroundColor(.textSecondary)
                    })
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                Text("Выберите даты или период")
                    .foregroundColor(.textSecondary)
                    .font(.textH3M18240())
                    .multilineTextAlignment(.center)
            }
            
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
                                action: closeAction
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
                                action: closeAction
                            )
                            .allowsHitTesting(selectedRange.rangeSelected == true ? false : true)
                            
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
            nil,
            selectedRange,
            [],
            {
                $0
                    .dayView(RangeSelector.init)
                    .scrollTo(date: Date())
            }
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

struct RangeSelector: DayView {
    
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
    
    func onSelection() {
        
        selectDate(date)
    }
}
