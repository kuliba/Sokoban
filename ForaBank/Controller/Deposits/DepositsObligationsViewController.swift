/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import FlexiblePageControl
import Hero

class DepositsObligationsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!

    let cellId = "DepositsObligationsCell"

    @IBOutlet weak var activityIndicator: ActivityIndicatorView!

    //    let data_ = [
//        ["deposits_obligations_afk",
//         "АФК-Система, Sistema-19",
//         "Предложений по бумаге нет",
//         "8,83%"
//        ],
//
//        ["deposits_obligations_gazprom",
//         "Газпром, GAZ-37",
//         "Предложений по бумаге нет",
//         "5,37%"
//        ],
//
//        ["deposits_obligations_veb",
//         "ВЭБ, VEB-23",
//         "Предложений по бумаге нет",
//         "4,04%"
//        ],
//
//        ["deposits_obligations_rosnef",
//         "Роснэфть, RosNef-22",
//         "Гипермаркет",
//         "3,84%"
//        ]
//    ]

    var bonds = [Bond]() {
        didSet {
            tableView.reloadData()
            activityIndicator.stopAnimating()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (bonds == nil) {
            activityIndicator.startAnimation()

        }


    }




    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimation()
        setUpTableView()

    }



    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NetworkManager.shared().getBonds { (success, bonds) in
            if success {
                self.bonds = bonds ?? []
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DepositObligationDetailsViewController {
            destination.bonds = bonds[(tableView.indexPathForSelectedRow?.row)!]
        }

    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            // tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
}

// MARK: - UITableView DataSource and Delegate
extension DepositsObligationsViewController: UITableViewDataSource, UITableViewDelegate {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bonds.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsObligationsCell else {
            fatalError()
        }

        cell.titleLabel.text = bonds[indexPath.row].depositProductName
        cell.subTitleLabel.text = maskedCard(with: bonds[indexPath.row].accountNumber!)
        cell.descriptionLabel.text = maskSum(sum: bonds[indexPath.row].balance!)
        cell.currently.text = bonds[indexPath.row].currencyCode

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {

            let footerView = UIView(frame: CGRect(x: tableView.frame.minX + 20, y: 0, width: tableView.frame.width - 40, height: 95))
            let doneButton = UIButton(type: .system)
            doneButton.frame = CGRect(x: footerView.frame.minX, y: footerView.frame.minY + 15, width: footerView.frame.width, height: 45)

            doneButton.setTitle("Открыть вклад", for: .normal)

            doneButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)

            doneButton.setTitleColor(.black, for: [])


            doneButton.layer.borderWidth = 0.5
            doneButton.layer.borderColor = UIColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1).cgColor

            doneButton.layer.cornerRadius = doneButton.frame.height / 2


            footerView.addSubview(doneButton)
            return footerView
        }

        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DepositObligationDetailsViewController", sender: nil)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 95
    }
}

// MARK: - Private methods
private extension DepositsObligationsViewController {
    func presentPaymentsDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentsDetailsViewController") as? PaymentsDetailsViewController {
            present(vc, animated: true, completion: nil)
        }
    }
}


// MARK: - Private methods
private extension DepositsObligationsViewController {

    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewContentInsets()
        setAutomaticRowHeight()
        registerNibCell()
    }

    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    func setTableViewContentInsets() {
        tableView.contentInset.top = 15
    }

    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }

    func registerNibCell() {
        let nibTemplateCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibTemplateCell, forCellReuseIdentifier: cellId)
    }

    func setSearchView() {
        guard let searchCell = UINib(nibName: "DepositsSearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? UIView else {
                return
        }
        let searchView = UIView(frame: searchCell.frame)
        searchView.addSubview(searchCell)
        tableView.tableHeaderView = searchView
    }
}

