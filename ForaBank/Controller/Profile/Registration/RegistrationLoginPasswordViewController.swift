//
//  RegistrationLoginPasswordViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 31/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import FlexiblePageControl
import Hero

class RegistrationLoginPasswordViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var continueButton: ButtonRounded!
    @IBOutlet weak var pageControl: FlexiblePageControl!
    @IBOutlet weak var centralView: UIView!
    
    var segueId: String? = nil
    var backSegueId: String? = nil
//    let pageControl = FlexiblePageControl()
    let gradientView = UIView()
    let circleView = UIView()
    
    // MARK: - Actions
    @IBAction func backButtonCLicked(_ sender: Any) {
        segueId = backSegueId
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradientLayerView()
//        addCircleView()
        if pageControl != nil {
            setUpPageControl()
        }
        view.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = navigationController as? ProfileNavigationController {
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
                nav.pageControl.setCurrentPage(at: 2)
            }, completion: nil)
        }
        if segueId == "loginPassword" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0))
            ]
        }
        if segueId == "permissions" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView?.hero.modifiers = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "loginPassword" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0))
            ]
        }
        if segueId == "permissions" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView?.hero.modifiers = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueId = nil
        if let vc = segue.destination as? RegistrationPermissionsViewController {
            segueId = "permissions"
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
    }
}

//MARK: - Private methods
private extension RegistrationLoginPasswordViewController {
    // MARK: - Methods
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
        pageControl.numberOfPages = 4
        pageControl.pageIndicatorTintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 234/255, green: 68/255, blue: 66/255, alpha: 1)
        
        let config = FlexiblePageControl.Config(
            displayCount: 4,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.2,
            mediumDotSizeRatio: 0.5
        )
        
        pageControl.setConfig(config)
        pageControl.animateDuration = 0
        pageControl.setCurrentPage(at: 2)
    }
}
