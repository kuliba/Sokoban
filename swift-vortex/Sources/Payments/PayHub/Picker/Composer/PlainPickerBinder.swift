//
//  PlainPickerBinder.swift
//  
//
//  Created by Igor Malyarov on 30.08.2024.
//

import FlowCore

public typealias PlainPickerBinder<Element, Navigation> = Binder<PlainPickerContent<Element>, FlowDomain<Element, Navigation>.Flow>
