//
//  ServicesViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 01/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ServicesViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let serviceCellId = "ServicesCell"
    
    let data_ = [
        [
            Service(name: "Отделения",             description: "< 100м", iconName: "services_departments",    isPartner: false),
            Service(name: "Банкоматы",             description: "< 50м",  iconName: "services_atms",           isPartner: false),
            Service(name: "Платежные устройства",  description: "< 50м",  iconName: "services_paymentdevices", isPartner: false)
        ], [
            Service(name: "Такси",                 description: "от 90₽",  iconName: "services_taxi",          isPartner: true),
            Service(name: "Билеты в кино",         description: "от 350₽", iconName: "services_movietickets",  isPartner: true),
            Service(name: "Просмотр ТВ",           description: "от 199₽", iconName: "services_tv",            isPartner: true),
            Service(name: "Скидки в магазинах",    description: "до 80%",  iconName: "services_sales",         isPartner: true),
            Service(name: "Бронирование гостиниц", description: "до 30%",  iconName: "services_hotels",        isPartner: true),
            Service(name: "Ж/Д и авиабилеты",      description: "до 40%",  iconName: "services_tickets",       isPartner: true),
            Service(name: "Страховка",             description: "до 50%",  iconName: "services_insurance",     isPartner: true)
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewDelegateAndDataSource()
        setAutomaticRowHeight()
        registerNibCell()
        setSearchView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

// MARK: - UITableView DataSource and Delegate
extension ServicesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: serviceCellId, for: indexPath) as? ServicesCell else {
            fatalError()
        }
        
        cell.titleLabel.text = data_[indexPath.section][indexPath.row].name
        cell.additionalTitleLabel.text = data_[indexPath.section][indexPath.row].description
        cell.logoImageView.image = UIImage(named: data_[indexPath.section][indexPath.row].iconName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ServicesHeader
        
        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        headerView.backgroundColor = .clear
        headerCell.titleLabel.text = section == 0 ? "Услуги ФораБанка" : "Партнерские сервисы"
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // performSegue(withIdentifier: "", sender: indexPath.row)
    }
}

// MARK: - Private methods
private extension ServicesViewController {
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func registerNibCell() {
        let nibCell = UINib(nibName: serviceCellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: serviceCellId)
    }
    
    func setSearchView() {
        guard let searchCell = UINib(nibName: "ServicesSearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? UIView else {
                return
        }
        let searchView = UIView(frame: searchCell.frame)
        searchView.addSubview(searchCell)
        tableView.tableHeaderView = searchView
    }
}
