//
//  DepositBottomSheetItemViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import Foundation
import SwiftUI

class DepositBottomSheetItemViewModel: Identifiable {

    let id: String
    let term: Int
    let rate: Double
    let termName: String

    init(id: String = UUID().uuidString,
         term: Int,
         rate: Double,
         termName: String) {

        self.id = id
        self.term = term
        self.rate = rate
        self.termName = termName
    }
}
