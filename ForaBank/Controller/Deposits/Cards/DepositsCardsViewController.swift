//
//  DepositsCardsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 18/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsCardsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var selector: UIView!
    @IBOutlet weak var card1: UIView!
    @IBOutlet weak var card2: UIView!
    @IBOutlet weak var card3: UIView!
    @IBOutlet weak var card4: UIView!

    @IBOutlet weak var addCardButton: UIButton!
    
    // соотношение между сторонами карты - 1.75
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DepositsCardsViewController viewDidLoad")
        selector.layer.cornerRadius = 3
        
        addCardButton.layer.cornerRadius = addCardButton.frame.height / 2
        addCardButton.backgroundColor = .clear
        addCardButton.layer.borderWidth = 1
        addCardButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.25).cgColor
        
        card1.layer.cornerRadius = 10
        card2.layer.cornerRadius = 10
        card3.layer.cornerRadius = 10
        card4.layer.cornerRadius = 10
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector (cardViewClicked (_:)))
        card4.addGestureRecognizer(gesture)
        
        picker.layer.cornerRadius = 3
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DepositsCardsViewController viewWillAppear")
    }

    
    // MARK: - Methods
    @objc func cardViewClicked(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "CardListOnholdNavigation", sender: nil)
    }
}
