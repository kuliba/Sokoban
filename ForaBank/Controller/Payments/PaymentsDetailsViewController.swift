//
//  PaymentsDetailsViewController.swift
//  ForaBank
//
//  Created by IM on 05/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class PaymentsDetailsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var comissionTextField: UITextField!
    @IBOutlet weak var containterView: RoundedEdgeView!
    
    // MARK: - Actions
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPicker()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientView() // TODO: Replace with GradientView view
    }
}

// - MARK: Private methods
private extension PaymentsDetailsViewController {
    func setUpPicker() {
        picker.layer.cornerRadius = 3
        pickerImageView.image = pickerImageView.image?.withRenderingMode(.alwaysTemplate)
        pickerImageView.tintColor = .white
    }
    
    func addGradientView() {
        let containerGradientView = GradientView()
        containerGradientView.frame = containterView.frame
        containerGradientView.color1 = UIColor(red: 242/255, green: 173/255, blue: 114/255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 236/255, green: 69/255, blue: 68/255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }
}
