//
//  ConfurmPaymentsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 18.06.2021.
//

import UIKit

class ConfurmPaymentsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        let button = UIButton(title: "На главную", titleColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), isBorder: true)
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        
        
//        let stackView = UIStackView(arrangedSubviews: [])
//        stackView.axis = .vertical
//        stackView.alignment = .fill
//        stackView.distribution = .equalSpacing
//        stackView.spacing = 20
//        view.addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
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
