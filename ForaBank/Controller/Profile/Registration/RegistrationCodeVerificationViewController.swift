//
//  RegistrationCodeVerificationViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 25/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import FlexiblePageControl

class RegistrationCodeVerificationViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var codeNumberTextField: UITextField!
    @IBOutlet weak var continueButton: ButtonRounded!
    @IBOutlet weak var pageControl: FlexiblePageControl!
    
//    let pageControl = FlexiblePageControl()
    let gradientView = UIView()
    let circleView = UIView()
    
    // MARK: - Actions
    @IBAction func backButtonCLicked(_ sender: Any) {
        view.endEditing(true)
//        UIView.animate(
//            withDuration: 0.35,
//            animations: {
//                self.gradientView.alpha = 0
//        },
//            completion: { _ in
//                self.dismiss(animated: false)
                self.navigationController?.popViewController(animated: true)
//        })
    }
    @IBAction func continueButtonClicked(_ sender: Any) {
        view.endEditing(true)
//        print("continueButtonClicked")
        NetworkManager.shared().checkVerificationCode(code: self.codeNumberTextField.text ?? "") { [unowned self] (success) in
            if success {
                let rootVC:ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                if let t = self.tabBarController as? TabBarController {
                    t.setNumberOfTabsAvailable()
                }
                self.navigationController?.setViewControllers([rootVC], animated: true)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradientLayerView()
        addCircleView()
        if pageControl != nil {
            setUpPageControl()
        }
        
        codeNumberTextField.delegate = self
        view.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        UIView.animate(withDuration: 0.25) {
//            self.gradientView.alpha = 1
//        }
    }
}

// MARK: - Private methods
private extension RegistrationCodeVerificationViewController {
    func addGradientLayerView() {
        gradientView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor(red: 241/255, green: 176/255, blue: 116/255, alpha: 1).cgColor, UIColor(red: 237/255, green: 73/255, blue: 73/255, alpha: 1).cgColor]
        gradientView.layer.addSublayer(gradientLayer)
//        gradientView.alpha = 0
        view.insertSubview(gradientView, at: 0)
    }
    
    func addCircleView() {
        circleView.frame = CGRect(x: 0, y: 0, width: view.frame.width * 5, height: view.frame.width * 5)
        circleView.center = view.center
        circleView.frame.origin.y = UIDevice.hasNotchedDisplay ? 90 : 67
        circleView.backgroundColor = .clear
        let layer = CAShapeLayer()
        layer.path = CGPath(ellipseIn: circleView.bounds, transform: nil)
        layer.fillColor = UIColor.white.cgColor
        circleView.layer.addSublayer(layer)
        circleView.clipsToBounds = true
        view.insertSubview(circleView, at: 1)
    }
    
    func setUpPageControl() {
        pageControl.numberOfPages = 12
        pageControl.pageIndicatorTintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 234/255, green: 68/255, blue: 66/255, alpha: 1)
        
        let config = FlexiblePageControl.Config(
            displayCount: 6,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.5,
            mediumDotSizeRatio: 0.5
        )
        
        pageControl.setConfig(config)
        
        pageControl.center.x = view.center.x
        pageControl.frame.origin.y = 10
        containerView.addSubview(pageControl)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        continueButton.isHidden = count < 3
        return count <= 3
    }
}
