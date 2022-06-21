//
//  UIApplication+Extension.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.06.2022.
//

import UIKit

extension UIApplication {

    static var safeAreaInsets: UIEdgeInsets {

        guard let safeAreaInsets = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets else {
            return .zero
        }

        return safeAreaInsets
    }

    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
