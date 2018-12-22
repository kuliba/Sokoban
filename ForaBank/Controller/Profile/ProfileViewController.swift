//
//  ProfileViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 26/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero

class ProfileViewController: UIViewController {

    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var segueId: String? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Александр\nКрюков"
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
