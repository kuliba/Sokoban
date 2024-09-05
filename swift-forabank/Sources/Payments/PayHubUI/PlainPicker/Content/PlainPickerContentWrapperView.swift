//
//  PlainPickerContentWrapperView.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PlainPickerContentWrapperView<ContentView, Element> = RxWrapperView<ContentView, PickerContentState<Element>, PickerContentEvent<Element>, PickerContentEffect> where ContentView: View
