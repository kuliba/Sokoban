//
//  KeyboardPublisher.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.06.2022.
//

import SwiftUI
import Combine

class KeyboardPublisher: ObservableObject  {
    
    let keyboardHeight: CurrentValueSubject<CGFloat, Never>
    let isKeyboardPresented: CurrentValueSubject<Bool, Never>

    private var bindings = Set<AnyCancellable>()

    init() {

        keyboardHeight = .init(0)
        isKeyboardPresented = .init(false)

        bind()
    }

    private func bind() {

        Publishers.keyboardHeight
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] keyboardHeight in
                
                self.keyboardHeight.value = keyboardHeight

            }.store(in: &bindings)

        Publishers.isKeyboardPresented
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isKeyboardPresented in

                self.isKeyboardPresented.value = isKeyboardPresented
                
            }.store(in: &bindings)
    }
}
