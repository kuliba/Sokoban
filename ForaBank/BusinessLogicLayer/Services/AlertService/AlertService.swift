//
//  AlertService.swift
//  ForaBank
//
//  Created by Бойко Владимир on 11.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class AlertService: IAlertService {
    static let shared = AlertService()

    private(set) var alerts = [UIAlertController]()
    private(set) var isAlertShown = false

    func show(title: String?, message: String?, cancelButtonTitle: String?, okButtonTitle: String?, cancelCompletion: ((_ action: UIAlertAction) -> Void)?, okCompletion: ((_ action: UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if isDuplicated(alert: alert) {
            return
        }

        if let title = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: title, style: .cancel, handler: { [weak self](_ action: UIAlertAction) -> Void in
                alert.dismiss(animated: true, completion: nil)
                cancelCompletion?(action)
                self?.handleAlertDissmissing()
            })
            alert.addAction(cancelAction)
        }

        if let title = okButtonTitle {
            let okAction = UIAlertAction(title: title, style: .default, handler: { [weak self](_ action: UIAlertAction) -> Void in
                alert.dismiss(animated: true, completion: nil)
                okCompletion?(action)
                self?.handleAlertDissmissing()
            })
            alert.addAction(okAction)
        }

        if isAlertShown == false {
            topMostVC()?.present(alert, animated: true, completion: nil)
        }
        isAlertShown = true
        alerts.append(alert)
    }

    func removeAllAlerts() {
        if let alert = alerts.first {
            alert.dismiss(animated: false, completion: nil)
        }

        alerts.removeAll()
        isAlertShown = false
    }

    private func isDuplicated(alert: UIAlertController) -> Bool {
        for localAlert in alerts {
            if localAlert.title == alert.title && localAlert.message == alert.message {
                return true
            }
        }
        return false
    }

    private func handleAlertDissmissing() {
        isAlertShown = false
        if alerts.count > 0 {
            alerts.removeFirst()
        }

        if let alert = alerts.first {
            topMostVC()?.present(alert, animated: true, completion: nil)
        }
    }
}
