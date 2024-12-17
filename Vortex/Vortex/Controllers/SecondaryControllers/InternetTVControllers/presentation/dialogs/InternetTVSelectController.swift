//
//  InternetTVSelectController.swift
//  ForaBank
//
//  Created by Роман Воробьев on 06.12.2021.
//

import Foundation
import UIKit

class InternetTVSelectController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    override var preferredContentSize : CGSize
    {
        get
        {
            if stackView != nil && presentingViewController != nil
            {
                return stackView.sizeThatFits(presentingViewController!.view.bounds.size)
            }
            else
            {
                return super.preferredContentSize
            }
        }

        set {super.preferredContentSize = newValue}

    }
}

