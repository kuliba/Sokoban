//
//  DepositsCardsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 18/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsCardsViewController: UIViewController {

    @IBOutlet weak var selector: UIView!
    @IBOutlet weak var card1: UIView!
    @IBOutlet weak var card2: UIView!
    @IBOutlet weak var card3: UIView!
    @IBOutlet weak var card4: UIView!

    @IBOutlet weak var addCardButton: UIButton!
    
    // соотношение 1.75 между сторонами карты
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selector.layer.cornerRadius = 3
        
        addCardButton.layer.cornerRadius = addCardButton.frame.height / 2
        addCardButton.backgroundColor = .clear
        addCardButton.layer.borderWidth = 1
        addCardButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.25).cgColor
        
        card1.layer.cornerRadius = 10
        card2.layer.cornerRadius = 10
        card3.layer.cornerRadius = 10
        card4.layer.cornerRadius = 10
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (cardViewClicked (_:)))
        card4.addGestureRecognizer(gesture)
    }
    
    @objc func cardViewClicked(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "DepositsCardsDetailsViewController", sender: nil)
    }
}
