//
//  String.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit

extension String {

    /// конвертирует имя контролева из String значения в UIViewController
    func getViewController() -> UIViewController? {
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            print("CFBundleName - \(appName)")
            if let viewControllerType = NSClassFromString("\(appName).\(self)") as? UIViewController.Type {
                return viewControllerType.init()
            }
        }
        return nil
    }

}
