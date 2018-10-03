//
//  PaymentsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 02/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

protocol Payment {
    var iconName: String { get }
    var name: String { get }
}

struct PaymentTemplate: Payment {
    let iconName: String
    let name: String
    
    let subtitle: String
    let description: String
}

struct PaymentTransfer: Payment {
    let iconName: String
    let name: String
}

struct PaymentService: Payment {
    let iconName: String
    let name: String
}

class PaymentsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let templateCellId = "PaymentTemplateCell"
    let paymentCellId = "PaymentCell"
    
    let data_: [[Payment]] = [
        [
            PaymentTemplate(iconName: "payments_template_alfabank", name: "Моя альфа", subtitle: "Последний: 1 июня", description: "50 ₽"),
            PaymentTemplate(iconName: "payments_template_beeline", name: "Мобилка мск", subtitle: "Последний: 2 июля", description: "500 ₽"),
            PaymentTemplate(iconName: "payments_template_sberbank", name: "Катюхин сбер", subtitle: "Последний: 3 августа", description: "5000 ₽")
        ], [
            PaymentTransfer(iconName: "payments_transfer_between-accounts", name: "Между своими счетами"),
            PaymentTransfer(iconName: "payments_transfer_to-bank-client", name: "Клиенту банка"),
            PaymentTransfer(iconName: "payments_transfer_to-another-bank", name: "В другой банк на счет или карту"),
            PaymentTransfer(iconName: "payments_transfer_money-request", name: "Запросить деньги на счет"),
            PaymentTransfer(iconName: "payments_transfer_to-online-wallet", name: "На электронный кошелек"),
            PaymentTransfer(iconName: "payments_transfer_charity", name: "Благотворительность")
        ], [
            PaymentService(iconName: "payments_services_phone-billing", name: "Мобильная связь"),
            PaymentService(iconName: "payments_services_fines-taxes-government-services", name: "Штрафы, налоги и государственные услуги"),
            PaymentService(iconName: "payments_services_utilities", name: "Коммунальные услуги ЖКХ"),
            PaymentService(iconName: "payments_services_internet_tv_phone", name: "Интернет, телевидение, телефон"),
            PaymentService(iconName: "payments_services_social-networks-gaming", name: "Социальные сети, онлайн игры"),
            PaymentService(iconName: "payments_services_security-systems", name: "Охранные системы"),
            PaymentService(iconName: "payments_services_transportation-cards", name: "Транспортные карты"),
            PaymentService(iconName: "payments_services_network-marketing", name: "Сетевой маркетинг"),
            PaymentService(iconName: "payments_services_other", name: "Прочее")
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewDelegateAndDataSource()
        setAutomaticRowHeight()
        registerNibCell()
        
        tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
}

// MARK: - UITableView DataSource and Delegate
extension PaymentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = data_[indexPath.section]
        let index = indexPath.row
        
        
        
        if let templates = section as? [PaymentTemplate],
            let templateCell = tableView.dequeueReusableCell(withIdentifier: templateCellId, for: indexPath) as? PaymentTemplateCell {
            templateCell.titleLabel.text = templates[index].name
            templateCell.subTitleLabel.text = templates[index].subtitle
            templateCell.descriptionLabel.text = templates[index].description
            templateCell.iconImageView.image = UIImage(named: templates[index].iconName)
            
            templateCell.bottomSeparatorView.isHidden = index == templates.endIndex - 1
            
            return templateCell
        } else if let transfers = section as? [PaymentTransfer],
            let transferCell = tableView.dequeueReusableCell(withIdentifier: paymentCellId, for: indexPath) as? PaymentCell {
            
            transferCell.iconImageView.image = UIImage(named: transfers[index].iconName)
            transferCell.titleLabel.text = transfers[index].name
            
            transferCell.bottomSeparatorView.isHidden = index == transfers.endIndex - 1
            
            return transferCell
        } else if let services = section as? [PaymentService],
            let serviceCell = tableView.dequeueReusableCell(withIdentifier: paymentCellId, for: indexPath) as? PaymentCell {
            
            serviceCell.iconImageView.image = UIImage(named: services[index].iconName)
            serviceCell.titleLabel.text = services[index].name
            
            
            serviceCell.bottomSeparatorView.isHidden = index == services.endIndex - 1
            
            
            return serviceCell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ServicesHeader
        
        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        
        headerCell.titleLabel.text = {
            
            if section == 0 {
                return "Шаблоны"
            } else if section == 1 {
                return "Переводы"
            } else if section == 2 {
                return "Оплата услуг"
            } else {
                return ""
            }
        }()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            
            let footerView = UIView(frame: CGRect(x: tableView.frame.minX + 20, y: 0, width: tableView.frame.width - 40, height: 95))
            let doneButton = UIButton(frame: CGRect(x: footerView.frame.minX, y: footerView.frame.minY + 15, width: footerView.frame.width, height: 45))
            
            
            doneButton.setTitle("Создать шаблон", for: .normal)
            
            doneButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
            
            doneButton.setTitleColor(.black, for: [])
            
            
            doneButton.layer.borderWidth = 0.5
            doneButton.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).cgColor
            
            doneButton.layer.cornerRadius = doneButton.frame.height / 2
            
            
            footerView.addSubview(doneButton)
            return footerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 95
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Private methods
private extension PaymentsViewController {
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func registerNibCell() {
        let nibTemplateCell = UINib(nibName: templateCellId, bundle: nil)
        tableView.register(nibTemplateCell, forCellReuseIdentifier: templateCellId)
        
        let nibTransferCellIdCell = UINib(nibName: paymentCellId, bundle: nil)
        tableView.register(nibTransferCellIdCell, forCellReuseIdentifier: paymentCellId)
    }
}
