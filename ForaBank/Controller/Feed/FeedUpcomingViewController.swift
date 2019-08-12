//
//  FeedUpcomingViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 11/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedUpcomingViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    let data_ = [
        [
            "feed_upcoming_credit_gif", "Платеж по кредиту уже завтра", "Договор №4556***90", "Ежемесячный платеж", "23 450 ₽", "Остаток долга", "320 950 ₽", "Оплатить сейчас", "#FFFFFF", "#E84647", "Настроить", "#FFFFFF", "#FCFCFF"
        ], [
            "feed_upcoming_beeline_logo", "Ближайший платеж ожидается через два дня", "Услуги сотовой связи", "+7916*****79", "450 ₽", "Автоплатеж", "5 декабря", "Оплатить сейчас", "#000000", "#FFFFFF", "Настроить", "#F5BC31", "#F5BC31"
        ], [
            "feed_upcoming_akado_logo", "Создайте шаблон для своевременной оплаты", "Интернет и домашнее ТВ", "Ежемесячный платеж", "650 ₽", "Оплачено", "4 дня назад", "Создать шаблон", "#FFFFFF", "#E84647", "Настроить", "#FFFFFF", "#FFFFFF"
        ]
    ]
    
    let cellId = "FeedUpcomingCell"
    
    var cellHeight: CGFloat = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewDelegateAndDataSource()
        registerNibCell()
        //cellHeight = view.frame.height - 80 // - 49
        
        tableView.decelerationRate = .fast
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 44
        let tabBarHeight = self.parent?.tabBarController?.tabBar.frame.height ?? 49
        cellHeight = view.frame.height - tabBarHeight - topPadding - 25 // 25 - top constraint for FeedViewController container View
//        print(cellHeight)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print(tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as Any)
//
//    }
}

// MARK: - UITableView DataSource and Delegate
extension FeedUpcomingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? FeedUpcomingCell  else {
            fatalError()
        }
        //let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "play", withExtension: "gif")!)
//        guard let imageData = NSDataAsset(name: data_[indexPath.row][0]) else {
//            print("image named \"\(data_[indexPath.row][0])\" into NSData")
//            return
//        }
        //print(data_[indexPath.row][0] as Any)
        if data_[indexPath.row][0].range(of: "gif") != nil {
            //print("gif")
            let imageData = NSDataAsset(name: data_[indexPath.row][0])
            cell.logoImageView.image = UIImage.gifImageWithData(imageData!.data)
            cell.logoImageView.contentMode = .scaleAspectFill
        } else {
            //print("not gif")
            cell.logoImageView.image = UIImage(named: data_[indexPath.row][0])
            cell.logoImageView.contentMode = .scaleAspectFit
        }
        cell.titleLabel.text = data_[indexPath.row][1]
        cell.subtitleLabel.text = data_[indexPath.row][2]
        
        cell.position1name.text = data_[indexPath.row][3]
        cell.position1value.text = data_[indexPath.row][4]
        
        cell.position2name.text = data_[indexPath.row][5]
        cell.position2value.text = data_[indexPath.row][6]
        
        cell.button1.setTitle(data_[indexPath.row][7], for: [])
        cell.button1.setTitleColor(UIColor(hexFromString: data_[indexPath.row][8]), for: [])
        cell.button1.backgroundColor = UIColor(hexFromString: data_[indexPath.row][9])
        
        cell.button2.setTitle(data_[indexPath.row][10], for: [])
        
        cell.button2.backgroundColor = UIColor(hexFromString: data_[indexPath.row][11])
        
        cell.backgroundColor = UIColor(hexFromString: data_[indexPath.row][12])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        targetContentOffset.pointee = scrollView.contentOffset
//
//        let minSpace: CGFloat = 10.0
//
//        var mod: Double = 0
//        if velocity.y > 1 {
//            mod = 0.5
//        } else if velocity.y < -1 {
//            mod = -0.5
//        }
//
//        var cellToSwipe = Double(Float((scrollView.contentOffset.y)) / Float((cellHeight + minSpace))) + Double(0.5) + mod
//
//        if cellToSwipe < 0 {
//            cellToSwipe = 0
//        } else if cellToSwipe >= Double(tableView.numberOfRows(inSection: 0)) {
//            cellToSwipe = Double(tableView.numberOfRows(inSection: 0)) - Double(1)
//        }
//
//        let indexPath = IndexPath(row: Int(cellToSwipe), section:0)
//        tableView.scrollToRow(at:indexPath, at: .middle, animated: true)
//    }
}

// MARK: - Private methods
private extension FeedUpcomingViewController {
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func registerNibCell() {
        let nibCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: cellId)
    }
}
