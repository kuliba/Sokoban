/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import iCarousel
import DeviceKit
import Hero



class SettingsViewController: UIViewController
{

    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!

    @IBAction func backButtonClicked(_ sender: Any) {
        view.endEditing(true)
        segueId = backSegueId
        navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Properties

    let cellId = "FeedOptionCell"
    let options = [
        [
            FeedOption(name: "Смена пароля кода", iconName: "group choose", section: "Пользовательские настройки", button: true),
            FeedOption(name: "Смена пин кода", iconName: "group choose", section: "Пользовательские настройки", button: false),

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

    var gradientViews = [GradientView2]()
    var backSegueId: String? = nil
    var segueId: String? = nil

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
}

// MARK: - Private methods

private extension SettingsViewController {

    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setAutomaticRowHeight()
        registerNibCell()
    }

    func setTableViewDelegateAndDataSource() {
//        tableView.dataSource = self
//        tableView.delegate = self
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
