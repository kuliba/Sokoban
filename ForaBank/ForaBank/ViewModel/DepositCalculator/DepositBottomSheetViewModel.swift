//
//  DepositBottomSheetViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 03.05.2022.
//

import Foundation

class DepositBottomSheetViewModel: ObservableObject {

    @Published var selectedItem: DepositBottomSheetItemViewModel
    @Published var isShowBottomSheet: Bool


    let title: String
    var items: [DepositBottomSheetItemViewModel]
    let itemHeight: Int

    init(title: String = "Срок вклада",
         items: [DepositBottomSheetItemViewModel],
         itemHeight: Int = 100,
         selectedItem: DepositBottomSheetItemViewModel = .init(),
         isShowBottomSheet: Bool = false) {

        self.title = title
        self.items = items
        self.itemHeight = itemHeight
        self.selectedItem = selectedItem
        self.isShowBottomSheet = isShowBottomSheet
    }
}
