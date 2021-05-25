//
//  ForaActivityIndicator.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 28.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class ForaActivityIndicator: UIViewController{
    
    var foraIndicator = RefreshView()
    
    func indicatorBegin(){
        foraIndicator.startAnimation()
        foraIndicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    func endIndicator(){
        foraIndicator.stopAnimation()
        foraIndicator.stopAnimating()
        foraIndicator.isHidden = true
    }
    
}
