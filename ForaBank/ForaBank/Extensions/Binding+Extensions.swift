//
//  Binding.swift
//  ForaBank
//
//  Created by Дмитрий on 10.02.2022.
//

import Foundation
import SwiftUI

extension Binding where Value: Equatable {
    
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    static func bindOptional(_ source: Binding<Value?>, _ defaultValue: Value) -> Binding<Value> {
        self.init(get: {
            source.wrappedValue ?? defaultValue
        }, set: {
            source.wrappedValue = ($0 as? String) == "" ? nil : $0
        })
    }
}
