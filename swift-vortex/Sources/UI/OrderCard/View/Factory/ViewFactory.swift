//
//  ViewFactory.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation
import SelectorComponent
import SwiftUI
import UIPrimitives

public struct ViewFactory<Confirmation, ConfirmationView, SelectorView: View> {

    let makeConfirmationView: (Confirmation) -> ConfirmationView
    let makeIconView: MakeIconView
    let makeSelectorView: MakeSelectorView
    
    public init(
        @ViewBuilder makeConfirmationView: @escaping (Confirmation) -> ConfirmationView,
        makeIconView: @escaping MakeIconView,
        makeSelectorView: @escaping MakeSelectorView
    ) {
        self.makeConfirmationView = makeConfirmationView
        self.makeIconView = makeIconView
        self.makeSelectorView = makeSelectorView
    }
}

public extension ViewFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    typealias MakeSelectorView = (SelectorComponent.Selector<Product>, @escaping (SelectorComponent.SelectorEvent<Product>) -> Void) -> SelectorView
}
