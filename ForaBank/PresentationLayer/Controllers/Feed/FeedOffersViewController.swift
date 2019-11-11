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
    
    let cellId = "FeedOffersCell"
    let cellId2 = "FeedOfferCustom1Cell"
    
    
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

      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
     
    }
}


// MARK: - Private methods
