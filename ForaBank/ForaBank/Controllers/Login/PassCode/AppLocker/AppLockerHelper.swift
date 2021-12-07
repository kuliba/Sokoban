//
//  AppLockerHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.10.2021.
//

import UIKit
import RealmSwift

struct AppLockerHelper {
    
    static func goVC(_ mode: ALMode) {
        
        if AppDelegate.shared.isAuth ?? false {
            guard let topVc = UIApplication.getTopViewController() else {return}
            DispatchQueue.main.async {
                let locker: AppLocker = AppLocker.loadFromStoryboard()
                locker.mode = mode
                locker.modalPresentationStyle = .fullScreen
                topVc.present(locker, animated: true, completion: nil)
            }
        }
    }
    
}
