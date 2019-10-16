/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

struct FeedOption {
    let name: String
    let iconName: String
    let section: String
    let button: Bool?
}
struct FeedOptionPin {
    let name: String
    let iconName: String
    let section: String
}

class FeedOptionsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    
    
    let cellId = "FeedOptionCell"
    
    let options = [
        [
            FeedOption(name: "Смена пин-кода", iconName: "icon_profile_settings", section: "Авторизация", button: false),
           
        ], [
            FeedOption(name: "Счета", iconName: "feed_option_accounts", section: "Текущее", button: false),
            FeedOption(name: "Вклады", iconName: "feed_option_holdings", section: "Текущее", button: false),
            FeedOption(name: "Карты", iconName: "feed_option_cards", section: "Текущее", button: false),
            FeedOption(name: "Акции, облигации", iconName: "feed_option_stockbonds", section: "Текущее", button: false),
            FeedOption(name: "Ячейки", iconName: "feed_option_cells", section: "Текущее", button: false)
        ], [
            FeedOption(name: "Платежи и переводы", iconName: "feed_option_paymentstransactions", section: "Предстоящее", button: false),
            FeedOption(name: "Кредиты", iconName: "feed_option_credits", section: "Предстоящее", button: false),
            FeedOption(name: "Услуги и сервисы", iconName: "feed_option_services", section: "Предстоящее", button: false)
        ], [
            FeedOption(name: "Такси", iconName: "feed_option_taxi", section: "Предложения", button: false),
            FeedOption(name: "Билеты в кино", iconName: "feed_option_cinema", section: "Предложения", button: false),
            FeedOption(name: "Акции в магазинах", iconName: "feed_option_sales", section: "Предложения", button: false),
            FeedOption(name: "Бронирование гостиниц", iconName: "feed_option_hotelbooking", section: "Предложения", button: false),
            FeedOption(name: "Ж/Д и авиабилеты", iconName: "feed_option_trainsavia", section: "Предложения", button: false),
            FeedOption(name: "Страховка", iconName: "feed_option_insurance", section: "Предложения", button: false)
        ], [
            FeedOption(name: "Новости банка", iconName: "feed_option_banknews", section: "Инфо", button: false),
            FeedOption(name: "Изменение граф. работы", iconName: "feed_option_schedulechange", section: "Инфо", button: false),
            FeedOption(name: "Рекомендации", iconName: "feed_option_recomendations", section: "Инфо", button: false),
            FeedOption(name: "Курс валют", iconName: "feed_option_exchangerate", section: "Инфо", button: false),
            FeedOption(name: "Новое в приложении", iconName: "feed_option_updates", section: "Инфо", button: false)
        ]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
       
    }
}

// MARK: - UITableView Delegate and DataSource
extension FeedOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? FeedOptionCell else {
            fatalError()
        }
        
        cell.titleLabel.text = options[indexPath.section][indexPath.row].name
        cell.iconImageView.image = UIImage(named: options[indexPath.section][indexPath.row].iconName)

       
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ServicesHeader
        
        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        headerView.backgroundColor = .clear
        headerCell.titleLabel.text = options[section][0].section
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Private methods
private extension FeedOptionsViewController {
    
    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setAutomaticRowHeight()
        registerNibCell()
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
        let nibCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: cellId)
    }
}
