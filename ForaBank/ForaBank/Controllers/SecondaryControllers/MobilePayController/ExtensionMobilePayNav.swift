//
//  ExtensionMobilePayNav.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.09.2021.
//

import UIKit

extension MobilePayViewController {
    
    func setupNavBar() {
        
        navigationItem.title = "Оплата мобильной связи"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button") , style: .plain, target: self, action: #selector(backAction))
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .highlighted)
        
    }
    
    @objc func backAction(){
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
