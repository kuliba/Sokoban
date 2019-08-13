/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero

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
    @IBOutlet weak var containerView: RoundedEdgeView!
    
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
    private var isSignedUp: Bool? = nil {
        didSet {
            if isSignedUp != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NetworkManager.shared().isSignedIn { [unowned self] (flag) in
//            print("viewWillAppear \(flag)")
            self.isSignedUp = flag
        }
        containerView.hero.modifiers = [
            HeroModifier.duration(0.3),
            HeroModifier.delay(0.2),
            HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
        ]
        view.hero.modifiers = [
            HeroModifier.beginWith([HeroModifier.opacity(1)]),
            HeroModifier.duration(0.5),
            //            HeroModifier.delay(0.2),
            HeroModifier.opacity(0)
        ]
        containerView.hero.id = "content"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        containerView.hero.modifiers = [
            HeroModifier.duration(0.5),
            HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
        ]
        view.hero.modifiers = [
            HeroModifier.duration(0.5),
            HeroModifier.opacity(0)
        ]
        containerView.hero.id = "content"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
    }
}

// MARK: - UITableView DataSource and Delegate
extension PaymentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch isSignedUp {
        case true:
            return data_.count
        case false:
            return data_.count-1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = (isSignedUp == true) ? section : section+1
        return data_[s].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let s = (isSignedUp == true) ? indexPath.section : indexPath.section+1
        
        let section = data_[s]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PaymentsDetailsViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ServicesHeader
        
        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        
        headerCell.titleLabel.text = {
            let s = (isSignedUp == true) ? section : section+1

            if s == 0 {
                return "Шаблоны"
            } else if s == 1 {
                return "Переводы"
            } else if s == 2 {
                return "Оплата услуг"
            } else {
                return ""
            }
        }()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isSignedUp == true && section == 0 {
            
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
        if isSignedUp == true && section == 0 {
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
    
    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewContentInsets()
        setAutomaticRowHeight()
        registerNibCell()
    }
    
    func setTableViewContentInsets() {
        tableView.contentInset.top = -10
    }
    
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
