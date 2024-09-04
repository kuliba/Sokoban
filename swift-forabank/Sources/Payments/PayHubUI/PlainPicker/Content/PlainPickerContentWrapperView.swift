//
//  PlainPickerContentWrapperView.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PlainPickerContentWrapperView<ContentView, Element> = RxWrapperView<ContentView, PlainPickerContentState<Element>, PlainPickerContentEvent<Element>, PlainPickerContentEffect> where ContentView: View
