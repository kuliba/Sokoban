//
//  ProfileViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 26/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero
import Alamofire

class ProfileViewController: UIViewController {

    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: CircularImageView!
    
    var segueId: String? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        nameLabel.text = "Александр\nКрюков" //image_profile_samplephoto
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "SignedIn" {
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(1)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.forceNonFade,
                HeroModifier.opacity(1)
            ]
            menu.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(3)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: -view.frame.width, y: 0))
            ]
        }
        if segueId == "Registered" {
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(2)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.forceNonFade,
                HeroModifier.opacity(1),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            menu.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(3)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.translate(CGPoint(x: -view.frame.width, y: 0))
            ]
        }
        NetworkManager.shared().getProfile { [weak self] (success, profile, errorMessage) in
            if success,
                let firstName = profile?.firstName,
                let lastName = profile?.lastName {
                self?.nameLabel.text = "\(firstName)\n\(lastName)"
                
                if let imageUrl = profile?.imageURL {
                    if let image = UIImage(named: imageUrl){ //load from bundle
                        self?.userImageView.image = image
                    } else { //load image from url
                        //NEED AlamofireImage downloading
                        self?.userImageView.image = UIImage(named: "image_profile_samplephoto")
                    }
                } else { //default image
                    self?.userImageView.image = UIImage(named: "image_profile_samplephoto")
                }
            } else {
                print("ProfileViewController: \(errorMessage ?? "error without errorMessage")")
                self?.nameLabel.text = "Упс, что-то не загрузилось"//"Александр\nКрюков"//
                self?.userImageView.image = UIImage(named: "image_profile_samplephoto")
                if NetworkManager.shared().checkForClosingSession(errorMessage) == true {
                    let rootVC = self?.storyboard?.instantiateViewController(withIdentifier: "LoginOrSignupViewController") as! LoginOrSignupViewController
                    NetworkManager.shared().logOut { [weak self] (_) in
                        if let t = self?.navigationController?.tabBarController as? TabBarController {
                            t.setNumberOfTabsAvailable()
                        }
                    }
                    if let pvc = self?.parent as? ProfileViewController {
                        pvc.segueId = "logout"
                    }
                    rootVC.segueId = "logout"
                    self?.navigationController?.setViewControllers([rootVC], animated: true)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        menu.hero.modifiers = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "logout" {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: containerView.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
        view.hero.modifiers = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        if segue.identifier == "ChatDialogsViewController" {
            segueId = nil
        }
    }
}
