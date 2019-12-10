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
        cell.switch.isHidden = !option.isToggable
        cell.indexPath = indexPath
        cell.delegate = self
        cell.contentView.alpha = option.isActive ? 1 : 0.5
        cell.isUserInteractionEnabled = option.isActive

        if option.isToggable {
            cell.isToggable = option.isToggable
            switch option {
            case .allowedBiometricSignIn(let isToggleOn):
                cell.switch.isOn = isToggleOn()
                break
            case .allowedPasscode(let isToggleOn):
                cell.switch.isOn = isToggleOn()
                break
            default:
                break
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.item]
        switch option {
        case .changePassword:
            delegate?.didSelectOption(option: option)
            break
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ServicesHeader

        let option = options.first
        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        headerView.backgroundColor = .clear
        headerCell.titleLabel.text = option?.localizedFieldName
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

extension SettingsPresenter: FeedOptionCellDelegate {
    func didChangedSwitch(at indexPath: IndexPath) {
        let option = options[indexPath.item]
        switch option {
        case .allowedBiometricSignIn(_):
            option.toggleValueIfPossiable()
            break
        case .allowedPasscode(_):
            option.toggleValueIfPossiable()
            break
        default:
            break
        }
    }
}
