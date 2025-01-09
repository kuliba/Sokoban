//
//  PlainPickerContent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import RxViewModel

public typealias PlainPickerContent<Element> = RxViewModel<PickerContentState<Element>, PickerContentEvent<Element>, PickerContentEffect>
