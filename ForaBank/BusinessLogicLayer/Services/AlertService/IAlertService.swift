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

    func show(title: String?, message: String?, cancelButtonTitle: String?, okButtonTitle: String?, cancelCompletion: ((_ action: UIAlertAction) -> Void)?, okCompletion: ((_ action: UIAlertAction) -> Void)?)

    func show(title: String?, message: String?, cancelButtonTitle: String?, okButtonTitles: [String?], cancelCompletion: ((_ action: UIAlertAction) -> Void)?, okCompletions: [((_ action: UIAlertAction) -> Void)?])

    func removeAllAlerts()
}
