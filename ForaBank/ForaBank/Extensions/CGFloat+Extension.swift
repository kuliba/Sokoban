//
//  CGFloat+Extension.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.05.2023.
//

import UIKit

public extension CGFloat {
    
    func pixelsToPoints() -> CGFloat {
        return self / UIScreen.main.scale
    }
}
