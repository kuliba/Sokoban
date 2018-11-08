//
//  PopupPickerViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 06/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class PopupPickerViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var addButton: ButtonRounded!
    
    // MARK: - Actions
    @IBAction func addButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.backgroundColor = .clear
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
    }
}
