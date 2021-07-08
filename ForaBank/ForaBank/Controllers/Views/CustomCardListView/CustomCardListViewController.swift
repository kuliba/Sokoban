//
//  CustomCardListViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.07.2021.
//

import UIKit

class CustomCardListViewController: UIViewController {
    
    let xibView = CustomCardListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        xibView.frame = self.view.frame
        self.view.addSubview(self.xibView)
    }
    
}
