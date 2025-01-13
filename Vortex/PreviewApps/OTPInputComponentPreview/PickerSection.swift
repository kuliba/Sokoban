//
//  PickerSection.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

typealias Pickerable = RawRepresentable & CaseIterable & Identifiable & Hashable

protocol PickerDisplayable {
    
    var displayValue: String { get }
}

extension RawRepresentable where RawValue == String {
    
    var displayValue: String { self.rawValue }
}

extension RawRepresentable where RawValue == Int {
    
    var displayValue: String { self.rawValue.formatted() }
}

struct PickerSection<T: Pickerable & PickerDisplayable>: View
where T.AllCases: RandomAccessCollection {
    
    
    let title: String
    let selection: Binding<T>
    
    var body: some View {
        
        Section(title) {
            
            Picker(title, selection: selection) {
                
                ForEach(T.allCases) {
                    
                    Text($0.displayValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

//struct PickerSection_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        PickerSection()
//    }
//}
