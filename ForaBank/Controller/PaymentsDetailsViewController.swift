//
//  PaymentsDetailsViewController.swift
//  ForaBank
//
//  Created by IM on 05/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class PaymentsDetailsViewController: UIViewController {
    
    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var comissionTextField: UITextField!
    @IBOutlet weak var containterView: RoundedEdgeView!
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        picker.layer.cornerRadius = 3
        pickerImageView.image = pickerImageView.image?.withRenderingMode(.alwaysTemplate)
        pickerImageView.tintColor = .white
        
        
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let containerGradientView = GradientView()
        containerGradientView.frame = containterView.frame
        containerGradientView.color1 = UIColor(red: 242/255, green: 173/255, blue: 114/255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 236/255, green: 69/255, blue: 68/255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
