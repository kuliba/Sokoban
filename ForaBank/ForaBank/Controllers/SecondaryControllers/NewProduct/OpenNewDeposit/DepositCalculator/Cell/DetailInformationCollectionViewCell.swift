//
//  DetailInformationCollectionViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit

class DetailInformationCollectionViewCell: UICollectionViewCell {
    
    let cellReuse = "DetailInformationViewCell"
    private var elements: [DetailedСondition]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var viewModel: OpenDepositDatum? {
        didSet {
            configure()
        }
    }
    
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    
    private func setupTableView() {
        addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        tableView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            paddingTop: 20,
            paddingBottom: 20)
        tableView.register(UINib(nibName: cellReuse,
                                 bundle: nil),
                           forCellReuseIdentifier: cellReuse)
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        elements = viewModel.detailedСonditions

        /// design
        backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?.first ?? "")
        tableView.backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?.first ?? "")
        
    }
    
}

extension DetailInformationCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuse,
            for: indexPath) as? DetailInformationViewCell else {
                return UITableViewCell()
            }
        cell.backgroundColor = UIColor(hexString: viewModel?.generalСondition?.design?.background?.first ?? "")
        let element = elements?[indexPath.row]
        cell.viewModel = element
        if element?.enable ?? false {
            cell.detailLabel.textColor = UIColor(hexString: viewModel?.generalСondition?.design?.textColor?.first ?? "")
        } else {
            cell.detailLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }
        
        return cell
    }
    
}

