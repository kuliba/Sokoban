//
//  KeyboardPublisher.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.06.2022.
//

import SwiftUI
import Combine

class KeyboardPublisher: ObservableObject  {
    
    @Published var keyboardHeight: CGFloat
    @Published var isKeyboardPresented: Bool
    
    static let shared = KeyboardPublisher()

    private var bindings = Set<AnyCancellable>()

    init() {

        keyboardHeight = 0
        isKeyboardPresented = false

        bind()
    }

    private func bind() {

        Publishers.keyboardHeight
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] keyboardHeight in
                
                self.keyboardHeight = keyboardHeight

            }.store(in: &bindings)

        Publishers.isKeyboardPresented
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isKeyboardPresented in

                self.isKeyboardPresented = isKeyboardPresented
                
            }.store(in: &bindings)
    }
}
