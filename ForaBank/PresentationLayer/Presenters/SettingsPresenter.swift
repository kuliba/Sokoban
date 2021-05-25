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
        if cell.titleLabel.numberOfLines > 0 {
            cell.titleLabel.font = cell.titleLabel.font.withSize(15)
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
                cell.contentView.alpha = 1
                cell.isUserInteractionEnabled = true
                cell.switch.isOn = isToggleOn()
                break
            case .nonDisplayBlockProduct(let isToggleOn):
                cell.contentView.alpha = 1
                cell.isUserInteractionEnabled = true
                if UserDefaults.standard.value(forKey: "mySwitchValue") != nil, cell.switch.isOn != UserDefaults.standard.bool(forKey: "mySwitchValue"){
//                    UserDefaults.standard.set(cell.switch.isOn, forKey: "mySwitchValue")
                    cell.switch.isOn = UserDefaults.standard.bool(forKey: "mySwitchValue")
                } else if UserDefaults.standard.value(forKey: "mySwitchValue") == nil{
                    UserDefaults.standard.set(cell.switch.isOn, forKey: "mySwitchValue")
                    cell.switch.isOn = UserDefaults.standard.bool(forKey: "mySwitchValue")

                }   
                
//                cell.switch.isOn = UserDefaults.standard.bool(forKey: "mySwitchValue")
                break
            default:
                break
            }
        }
        return cell
    }

    // настройки таблица с настройками профиля
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.item]
        switch option {
        case .changePassword:
            delegate?.didSelectOption(option: option)
            break
        case .changePasscode:
            delegate?.didSelectOption(option: option)
            break
        case .allowedPasscode(_):
            delegate?.didSelectOption(option: option)
            break
        case .bankSPBDefoult:
            delegate?.didSelectOption(option: option)
            break
        case .nonDisplayBlockProduct:
            
            break
        case .blockUser:
            delegate?.didSelectOption(option: option)
            break
//        case .setUpApplePay:
//            delegate?.didSelectOption(option: option)
//            break
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
            delegate?.didSelectOption(option: option)
            break
        case .nonDisplayBlockProduct:
//                       option.toggleValueIfPossiable()
//                       delegate?.didSelectOption(option: option)
//            UserDefaults.standard.setValue(false, forKey: "mySwitchValue")

                       break
        default:
            break
        }
        delegate?.reloadData()
    }
}
