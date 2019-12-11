//
//  SettingsModuleConfigurator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation



class SettingsModuleConfigurator {

    func configureModuleForView<UIViewController>(view: UIViewController) {

        if let viewController = view as? SettingsViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: SettingsViewController) {
        let presenter = SettingsPresenterInitializer.createSettingsPresenter(withDelegate: viewController)
        viewController.presenter = presenter
        viewController.loadViewIfNeeded()
        viewController.setTable(delegate: presenter, dataSource: presenter)
        viewController.registerNibCell(cellName: FeedOptionCell.Constants.cellReuseIdentifier)
    }
}
