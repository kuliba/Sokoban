//
//  ITableViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IListViewController {
    associatedtype TableView

    var tableView: TableView! { get set }
    func setTable(delegate: UITableViewDelegate, dataSource: UITableViewDataSource)
    func registerNibCell(cellName: String)
    func reloadData()
}

extension IListViewController where Self.TableView: UITableView {

    func setTable(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
    }

    func registerNibCell(cellName: String) {
        let nibCell = UINib(nibName: cellName, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: cellName)
    }

    func reloadData() {
        tableView.reloadData()
    }
}
