//
//  DepositsStatsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 07/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsStatsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var monthCollectionView: UICollectionView!
    
    let reuseId = "cell"
    
    var months_ = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    var selectedMonth = -1
    let infiniteSize = 120
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let now = Date()
        let calendar = Calendar.current
        selectedMonth = calendar.component(Calendar.Component.month, from: now) //current month
        
//        var newMonths: [String]
//        if selectedMonth > months_.count/2 {
//            newMonths = months_[selectedMonth..<months_.count]
//        }
        
//        newMonths.append(contentsOf: months_)
        setUpCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        monthCollectionView.selectItem(at: IndexPath(row: infiniteSize/2+selectedMonth, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
}

// MARK: - UICollectionView DataSource and Delegate
extension DepositsStatsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infiniteSize//months_//
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let attrS = NSAttributedString(string: months_[indexPath.row % months_.count], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
        return CGSize(width: attrS.size().width+10, height: monthCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let monthToShow = months_[indexPath.row % months_.count]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MonthCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.monthLabel.text = monthToShow
        cell.isSelected = indexPath.row % months_.count == selectedMonth
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMonth = indexPath.row % months_.count
    }
}
    
// MARK: - monthCollectionView set up private methods
private extension DepositsStatsViewController {
    func setUpCollectionView() {
        setСollectionViewDelegateAndDataSource()
        registerCollectionViewCell()
        print(monthCollectionView)
    }
    
    func setСollectionViewDelegateAndDataSource() {
        monthCollectionView.dataSource = self
        monthCollectionView.delegate = self
    }
    
    func registerCollectionViewCell() {
        monthCollectionView.register(MonthCollectionViewCell.self, forCellWithReuseIdentifier: reuseId)
    }
}
