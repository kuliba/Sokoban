//
//  SettingsModuleInitializer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class SettingsModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet private weak var settingsViewController: SettingsViewController!

    override func awakeFromNib() {
        let configurator = SettingsModuleConfigurator()
        configurator.configureModuleForView(view: settingsViewController)
    }
}
