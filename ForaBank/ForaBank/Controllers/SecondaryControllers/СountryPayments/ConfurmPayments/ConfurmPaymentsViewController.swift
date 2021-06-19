//
//  ConfurmPaymentsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 18.06.2021.
//

import UIKit

class ConfurmPaymentsViewController: UIViewController {
    
//    let confurmView = ConfurmPaymentsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        
//        view.addSubview(confurmView)
//        confurmView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
//                           right: view.rightAnchor, paddingTop: 120, paddingLeft: 20, paddingRight: 20)
//        confurmView.layer.cornerRadius = 16
//        confurmView.clipsToBounds = true
        
        let button = UIButton(title: "На главную", titleColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), isBorder: true)
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        button.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                      right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
                      paddingRight: 20, height: 44)
        
        
       
        
        
    }
    
    @objc func doneButtonTapped() {
        print(#function)
//        self.view.window?.rootViewController?.presentedViewController!.dismiss(animated: true, completion: nil)
        dismissViewControllers()
        
    }
    
    // MARK:- Dismiss and Pop ViewControllers
    func dismissViewControllers() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
        


    }
    
}
