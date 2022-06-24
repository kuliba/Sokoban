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

                withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                    self.keyboardHeight = -keyboardHeight
                }
            }.store(in: &bindings)

        Publishers.isKeyboardPresented
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isKeyboardPresented in

                self.isKeyboardPresented = isKeyboardPresented
            }.store(in: &bindings)
    }
}
