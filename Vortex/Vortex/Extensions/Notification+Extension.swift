//
//  Notification+Extension.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.06.2022.
//

import UIKit

extension Notification {

    var height: CGFloat {

        if let height = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height {
            return height
        }

        return 0
    }
}
