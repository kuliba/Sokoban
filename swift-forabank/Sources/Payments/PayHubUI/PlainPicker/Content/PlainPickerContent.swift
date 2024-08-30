//
//  PlainPickerContent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import RxViewModel

public typealias PlainPickerContent<Element> = RxViewModel<PlainPickerContentState<Element>, PlainPickerContentEvent<Element>, PlainPickerContentEffect>
