//
//  String+openLink.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.09.2024.
//

import Foundation
import UIKit

extension String {
    
    func openLink() {
        
        guard let linkURL = URL(string: self) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(linkURL) {
            UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
        }
    }
}
