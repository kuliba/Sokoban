//
//   ExtensionPushHistoryViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.11.2021.
//

import UIKit

extension PushHistoryViewController {
    func setupNavBar() {
        
        navigationItem.title = "Центр уведомлений"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button") , style: .plain, target: self, action: #selector(backAction))
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .highlighted)
        
    }
    
    @objc func backAction() {
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
