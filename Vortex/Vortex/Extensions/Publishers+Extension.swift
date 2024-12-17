//
//  Publishers+Extension.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.06.2022.
//

import SwiftUI
import Combine

extension Publishers {

    static var showPublisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    }

    static var hidePublisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    }

    static var keyboardHeight: AnyPublisher<CGFloat, Never> {

        let keyboardWillShow = showPublisher.map { $0.height - UIApplication.safeAreaInsets.bottom }
        let keyboardWillHide = hidePublisher.map { _ in CGFloat(0) }

        return MergeMany(keyboardWillShow, keyboardWillHide)
            .eraseToAnyPublisher()
    }

    static var isKeyboardPresented: AnyPublisher<Bool, Never> {

        let keyboardWillShow = showPublisher.map { _ in true }
        let keyboardWillHide = hidePublisher.map { _ in false }

        return MergeMany(keyboardWillShow, keyboardWillHide)
            .eraseToAnyPublisher()
    }
}
