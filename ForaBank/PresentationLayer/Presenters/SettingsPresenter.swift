//
//  SettingsPresenter.swift
//  ForaBank
//
//  Created by Бойко Владимир on 05.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class SettingsPresenter: NSObject, ISettingsPresenter {
    let options: Array<UserSettingType>
    internal weak var delegate: SettingsPresenterDelegate?

    init(options: Array<UserSettingType>, delegate: SettingsPresenterDelegate) {
        self.options = options
        self.delegate = delegate
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsPresenter: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedOptionCell.Constants.cellReuseIdentifier, for: indexPath) as? FeedOptionCell else {
            fatalError()
        }

        let option = options[indexPath.item]
        cell.titleLabel.text = option.localizedName
        cell.iconImageView.image = UIImage(named: option.imageName)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "showChangePassword", sender: tableView.cellForRow(at: indexPath))
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ServicesHeader

        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        headerView.backgroundColor = .clear
//        headerCell.titleLabel.text = options[section][0].section
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}
