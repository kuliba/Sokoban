//
//  SelfConfiguringCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}
