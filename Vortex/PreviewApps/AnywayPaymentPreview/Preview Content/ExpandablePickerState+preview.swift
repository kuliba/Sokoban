//
//  ExpandablePickerState+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

extension ExpandablePickerState where Item == String {
    
    static var preview: Self {
        
        .init(
            items: [
                "aaa",
                "bbbb",
                "ccccc",
            ],
            selection: "bbbb",
            toggle: .collapsed
        )
    }
}
