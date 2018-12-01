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
    @IBOutlet weak var bubblesStatsScrollView: BubblesStatsScrollView!
    
    private let reuseId = "cell"
    
    private let sortedNames = [
        "Еда, продукты питания",
        "Снято наличными",
        "Межбанковские переводы",
        "Мобильная связь",
        "Одежда и обувь",
        "Коммунальные услуги",
    ]
    private let sortedColors = [
        UIColor(displayP3Red: 76/255, green: 158/255, blue: 135/255, alpha: 1),
        UIColor(displayP3Red: 50/255, green: 64/255, blue: 80/255, alpha: 1),
        UIColor(displayP3Red: 146/255, green: 161/255, blue: 242/255, alpha: 1),
        UIColor(displayP3Red: 110/255, green: 192/255, blue: 222/255, alpha: 1),
        UIColor(displayP3Red: 241/255, green: 200/255, blue: 84/255, alpha: 1),
        UIColor(displayP3Red: 221/255, green: 76/255, blue: 129/255, alpha: 1)
    ]
    
    private let data_: [String : [CGFloat]] = [
        "Еда, продукты питания" : [24567.07, 28567.07],
        "Снято наличными" : [31800.00, 14567.07],
        "Межбанковские переводы" : [7950.00, 10432.00],
        "Мобильная связь" : [5650.00, 520.00],
        "Одежда и обувь" : [14500.00, 2000.00],
        "Коммунальные услуги" : [9600.00, 7800.0]
    ]
    private var normalizedData_: [String : (CGFloat, CGFloat)] = [String : (CGFloat, CGFloat)]()
    private var bubbleRadiuses = [CGFloat]()
    private let minRadius: CGFloat = 50
    
    private var months_ = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    private var selectedMonth = -1 {
        didSet {
            print("selectedMonth didSet \(selectedMonth)")

            normalizeData(atIndex: selectedMonth%2)
            if selectedMonth > 0 && bubblesStatsScrollView.bubblesDelegate == nil {
                bubblesStatsScrollView.bubblesDelegate = self
            } else {
                bubblesStatsScrollView.updateBubbles()
            }
        }
    }
//    let infiniteSize = 120
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bubblesStatsScrollView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)

        setUpSelectedMonth()
        setUpCollectionView()
        monthCollectionView.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.9)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        monthCollectionView.selectItem(at: IndexPath(row: /*infiniteSize/2+*/selectedMonth, section: 0), animated: false, scrollPosition: .centeredHorizontally)
 
        bubblesStatsScrollView.contentOffset = CGPoint(
            x: -bubblesStatsScrollView.frame.width/2 + bubblesStatsScrollView.bubbleViews[0].center.x,
            y: -bubblesStatsScrollView.contentInset.top)
        bubblesStatsScrollView.baseOffset = bubblesStatsScrollView.contentOffset
    }
}

// MARK: - UICollectionView DataSource and Delegate
extension DepositsStatsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months_.count//infiniteSize//
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let attrS = NSAttributedString(string: months_[indexPath.row/* % months_.count*/], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
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
        selectedMonth = indexPath.row// % months_.count
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
    }
}

    
// MARK: - private methods
private extension DepositsStatsViewController {
    //MARK: - collectionView set up
    func setUpCollectionView() {
        setСollectionViewDelegateAndDataSource()
        registerCollectionViewCell()
    }
    
    func setСollectionViewDelegateAndDataSource() {
        monthCollectionView.dataSource = self
        monthCollectionView.delegate = self
    }
    
    func registerCollectionViewCell() {
        monthCollectionView.register(MonthCollectionViewCell.self, forCellWithReuseIdentifier: reuseId)
    }
    
    func setUpSelectedMonth() {
        let now = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(Calendar.Component.month, from: now)-1 //current month
        var newMonths = [String]()
        if currentMonth > months_.count/2 {
            let offset = currentMonth - months_.count/2
            newMonths.append(contentsOf: Array(months_[offset..<months_.count]))
            newMonths.append(contentsOf: Array(months_[0..<offset]))
            months_ = newMonths
        } else if currentMonth < months_.count/2 {
            let offset = months_.count/2 - currentMonth
            newMonths.append(contentsOf: Array(months_[months_.count-offset..<months_.count]))
            newMonths.append(contentsOf: Array(months_[0..<months_.count-offset]))
            months_ = newMonths
        }
        selectedMonth = months_.count/2
    }
    
    func normalizeData(atIndex index: Int) {
        var sortedData = data_.sorted { return $0.value[index] < $1.value[index] }
        //нормализуем вектор линейно чтобы минимальное ненулевое значение стало = 1
        var minValue: CGFloat = 0
        for (i, d) in sortedData.enumerated() {
            if d.value[index] == 0 { //пропускаем нулевые значения
                continue
            } else if minValue == 0 {
                minValue = d.value[index]
                sortedData[i].value[index] = 1
            } else {
                sortedData[i].value[index] = sortedData[i].value[index] / minValue
            }
        }
        //нормализуем вектор с помощью логарифма чтобы все значения были в диапазоне [1, 2]
        //потому что коэффициет на который будет умножаться радиус бабблов должен быть от 1 до 2
        //т.е. максимальный радиус баббла в два раза больше минимального
        //        print(sortedData)
        //        if sortedData.last?.value != 0 { //массив из нулей не имеет смысла нормализовывать
        //            let maxValue = log(sortedData.last?.value ?? 1)
        //            for d in sortedData {
        //                //sortedData[i].value = log(sortedData[i].value) / maxValue + 1
        //                normalizedData_[d.key] = (data_[d.key]! ,log(d.value) / maxValue + 1)
        //            }
        //        }
        //[1, 1.6]
        if sortedData.last?.value[index] != 0 { //массив из нулей не имеет смысла нормализовывать
            let maxValue = log(sortedData.last?.value[index] ?? 1)
            for d in sortedData {
                let a = data_[d.key]!
                normalizedData_[d.key] = (a[index] ,0.6 * log(d.value[index]) / maxValue + 1)
                
            }
        }
        print("normalizedData_ \(normalizedData_)")
        //        [(key: "Мобильная связь", value: 1.0), (key: "Межбанковские переводы", value: 1.1976584441147593), (key: "Коммунальные услуги", value: 1.306808807019915), (key: "Одежда и обувь", value: 1.5454839930812088), (key: "Еда, продукты питания", value: 1.8506437338200095), (key: "Снято наличными", value: 2.0)]
        
    }
}


//MARK: - bubblesStatsScrollView delegate
extension DepositsStatsViewController: BubblesStatsDelegate {
    func setup(bubbleView: BubbleStatsView, atIndex index: Int) {
//        print("setup(bubbleView: BubbleStatsView, atIndex index: Int)")
        bubbleView.textLabel.text = sortedNames[index]
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = " "
        var sum: NSNumber = 0
        if let a = data_[sortedNames[index]], a.count>0 {
//            print(selectedMonth%2)
            sum = NSNumber(value: Float(a[selectedMonth%2]))
        }
        bubbleView.secondTextLabel.text = formatter.string(from: sum)
        let fontScale = ((normalizedData_[sortedNames[index]]?.1 ?? 1) - 1) / 2 + 1
        
        bubbleView.secondTextLabel.font = UIFont.systemFont(ofSize: 16*(fontScale))
        bubbleView.backgroundColor = sortedColors[index]
    }
    
    func numberOfBubbleViews() -> Int {
        return normalizedData_.count
    }
    
    func radiusOfBubbleView(atIndex index: Int) -> CGFloat {
        return (normalizedData_[sortedNames[index]]?.1 ?? 1) * minRadius
    }
    
}
