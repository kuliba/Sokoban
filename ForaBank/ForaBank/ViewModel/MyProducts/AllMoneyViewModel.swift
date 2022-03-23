//
//  AllMoneyViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 08.03.2022.
//

import Combine
import UIKit

final class AllMoneyViewModel: ObservableObject {

    let navigationBar: NavigationBar
    let topView: TopView
    let items: [MyProductsSectionAllMoneyView.ViewModel]

    internal init(navigationBar: NavigationBar, topView: TopView, items: [MyProductsSectionAllMoneyView.ViewModel]) {

        self.navigationBar = navigationBar
        self.topView = topView
        self.items = items
    }
    
    struct NavigationBar {

        let title: String
        let addAction: () -> Void
    }
    
    struct TopView {

        let title: String
        let balance: String
        let buttonLabel: String
        let actionSubtitle: String
        let buttonAction: () -> Void
    }
}
