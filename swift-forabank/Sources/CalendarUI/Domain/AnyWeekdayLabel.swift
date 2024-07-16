//
//  AnyWeekdayLabel.swift
//  
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

public struct AnyWeekdayLabel: View {
    
    private let internalView: AnyView
    
    init<V: WeekdayLabel>(_ view: V) { internalView = view.erased() }
    public var body: some View { internalView }
}
