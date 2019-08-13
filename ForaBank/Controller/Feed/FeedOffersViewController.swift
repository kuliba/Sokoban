/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

protocol Offer {}

struct FeedOffer: Offer {
    let bgImageName: String
    let logoImageName: String
    let description: String
    let buttonTitle: String
}

struct FeedOfferCustom1: Offer {
    let bgImageName: String
    let logoImageName: String
    let description: String
    let buttonTitle: String
}
struct FeedOfferCustom2: Offer {
    let bgImageName: String
    let logoImageName: String
    let description: String
    let buttonTitle: String
}

class FeedOffersViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    let cellId = "FeedOffersCell"
    let cellId2 = "FeedOfferCustom1Cell"
    
    var cellHeight: CGFloat = 0
    
    let data_: [Offer] = [
        FeedOffer(bgImageName: "feed_offer_mvideo_bg", logoImageName: "feed_offer_mvideo_logo", description: "Портативная акустика в подарок при покупке Samsung Galaxy S8 в М.Видео", buttonTitle: "Показать магазины на карте"),
        FeedOffer(bgImageName: "feed_offer_perekrestok_bg", logoImageName: "feed_offer_perekrestok_logo", description: "Скидка 15% клиентам банка при покупке овощей и фруктов в «Перекрестке»", buttonTitle: "Показать магазины на карте"),
        FeedOffer(bgImageName: "feed_offer_rzd_bg", logoImageName: "feed_offer_rzd_logo", description: "Напоминаем, что каждый вторник с 8:00 до 9:00 билеты на rzd.ru гораздо дешевле", buttonTitle: "Перейти на rzd.ru"),
        FeedOfferCustom1(bgImageName: "feed_offer_pyaterochka_bg", logoImageName: "feed_offer_pyaterochka_logo", description: "В «Пятерочке» ваши регулярные покупки получаются дешевле", buttonTitle: "Подробное сравнение")
        // FeedOfferCustom2()
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewDelegateAndDataSource()
        registerNibCell()
        
        cellHeight = view.frame.height - 80 // - 49
        
        tableView.decelerationRate = .normal
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
}

// MARK: - UITableView DataSource and Delegate
extension FeedOffersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let offer = data_[indexPath.row] as? FeedOffer,
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? FeedOffersCell {
            cell.bgImageView.image = UIImage(named: offer.bgImageName)
            cell.logoImageView.image = UIImage(named: offer.logoImageName)
            cell.descriptionLabel.text = offer.description
            cell.button.setTitle(offer.buttonTitle, for: [])
            return cell
        } else if let offer = data_[indexPath.row] as? FeedOfferCustom1,
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as? FeedOfferCustom1Cell {
            cell.bgImageView.image = UIImage(named: offer.bgImageName)
            cell.logoImageView.image = UIImage(named: offer.logoImageName)
            cell.descriptionLabel.text = offer.description
            cell.button.setTitle(offer.buttonTitle, for: [])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        
        let minSpace: CGFloat = 10.0

        var mod: Double = 0
        if velocity.y > 1 {
            mod = 0.5
        } else if velocity.y < -1 {
            mod = -0.5
        }

        var cellToSwipe = Double(Float((scrollView.contentOffset.y)) / Float((cellHeight + minSpace))) + Double(0.5) + mod

        if cellToSwipe < 0 {
            cellToSwipe = 0
        } else if cellToSwipe >= Double(tableView.numberOfRows(inSection: 0)) {
            cellToSwipe = Double(tableView.numberOfRows(inSection: 0)) - Double(1)
        }
        
        let indexPath = IndexPath(row: Int(cellToSwipe), section:0)
        tableView.scrollToRow(at:indexPath, at: .middle, animated: true)
    }
}

// MARK: - Private methods
private extension FeedOffersViewController {
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func registerNibCell() {
        let nibCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: cellId)
        
        let nibCell2 = UINib(nibName: cellId2, bundle: nil)
        tableView.register(nibCell2, forCellReuseIdentifier: cellId2)
    }
}
