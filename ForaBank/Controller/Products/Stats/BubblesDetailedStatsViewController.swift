/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class BubblesDetailedStatsViewController: UIViewController {

    // MARK: - properties
    @IBOutlet weak var scrollView: UIScrollView!
    var bubblesDetailedStatsView: BubblesDetailedStatsView!
    
    private let data_: [[CGFloat]] = [
        [56, 35, 60, 63, 36],
        [51, 37, 55, 35],
        [45, 34, 50]
    ]
    private let logos: [[String]] = [
        ["stats_perek", "stats_av", "stats_kho", "stats_metro", "stats_5"],
        ["stats_vtb", "stats_raif", "stats_sber", "stats_alfa"],
        ["stats_mts", "stats_tele2", "stats_megafon"]
    ]
    private let colors: [[String]] = [
        ["23512D", "82BE3F", "DBB44B", "2F5DA5", "EB252A"],
        ["204C89", "FDF252", "4D9E3E", "EB252A"],
        ["EB252A", "1B1B1B", "4FA469"]
    ]
    private let titles: [[String]] = [
        ["PEREKRESTOK", "", "Dyadushka KHO", "METRO Store", ""],
        ["Банк ВТБ", "", "Сбербанк", ""],
        ["МТС", "", "Мегафон"]
    ]
    private let money: [[String]] = [
        ["4 550 ₽", "", "4 050 ₽", "4 950,00", ""],
        ["2 150 ₽", "", "3 500 ₽", ""],
        ["2 200 ₽", "", "2 800 ₽"]
    ]
    private var initOffset = CGPoint.zero
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bubblesDetailedStatsView = BubblesDetailedStatsView()
        scrollView.addSubview(bubblesDetailedStatsView)
        scrollView.delegate = self
        bubblesDetailedStatsView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = bubblesDetailedStatsView.calculateSize()
        
        var left: CGFloat = 0
        if scrollView.frame.width/2 > scrollView.contentSize.width/2 {
            left = scrollView.frame.width/2 - scrollView.contentSize.width/2
        }
        var top: CGFloat = 0
        if scrollView.frame.height/2 > scrollView.contentSize.height/2 {
            top = scrollView.frame.height/2 - scrollView.contentSize.height/2
        }
        

//        if bubblesStatsScrollView.bubbleViews[0].center.x < bubblesStatsScrollView.frame.width/2 {
//            left = bubblesStatsScrollView.frame.width/2 - bubblesStatsScrollView.bubbleViews[0].center.x
//        }
        scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: 0, right: 0)
        initOffset = CGPoint(
            x: -scrollView.frame.width/2 + bubblesDetailedStatsView.centralBubbleCenter().x,
            y: -scrollView.contentInset.top)
//        print("initOffset \(initOffset)")
        scrollView.contentOffset = initOffset
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BubblesDetailedStatsViewController: BubblesDetailedStatsDelegate {
    func setUpView(atIndexPath index: IndexPath) -> BubbleDetailedStatsView {
        var v: BubbleDetailedStatsView
        if titles[index.section][index.item] != "" {
            v = BubbleDetailedStatsView(withLabels: true)
            v.textLabel.text = titles[index.section][index.item]
            v.secondTextLabel.text = money[index.section][index.item]
        } else {
            v = BubbleDetailedStatsView(withLabels: false)
        }
        let image = UIImage(named: logos[index.section][index.item])
//        print("image?.size \(image?.size)")
        v.image = image
        v.backgroundColor = UIColor(hexFromString: colors[index.section][index.item])
        return v
    }
    
    func numberOfBubbleGroups() -> Int {
        return data_.count
    }
    
    func numberOfBubble(forGroupAtIndex index: Int) -> Int {
        return data_[index].count
    }
    
    func radiusOfBubbleView(atIndexPath index: IndexPath) -> CGFloat {
        return data_[index.section][index.item]
    }
    
    func bubblesMargin() -> Double {
        return 3
    }
}

extension BubblesDetailedStatsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll \(scrollView.contentOffset)")
        bubblesDetailedStatsView.calculateScales(forXOffset: scrollView.contentOffset.x - initOffset.x, maxOffset: scrollView.frame.width/2)
//        bubblesDetailedStatsView.layoutIfNeeded()
    }
}
