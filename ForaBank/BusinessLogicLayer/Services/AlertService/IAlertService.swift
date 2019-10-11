//
//  IAlertService.swift
//  ForaBank
//
//  Created by Бойко Владимир on 11.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IAlertService {
    var isAlertShown: Bool { get }

    //swiftlint:disable:next function_parameter_count
    func show(title: String?, message: String?, cancelButtonTitle: String?, okButtonTitle: String?, cancelCompletion: ((_ action: UIAlertAction) -> Void)?, okCompletion: ((_ action: UIAlertAction) -> Void)?)
    func removeAllAlerts()
}
