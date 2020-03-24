//
//  MainVC.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 19.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class SectionTV{
    var name = "" //название секции
    var arrayCell = [CellTableView]() //ячейки секции
    var expanded: Bool // определяет состояние ячейки (скрыта/раскрыта)
    
    init(name:String, arrayCell:Array<CellTableView>, expanded:Bool) {
        self.name = name
        self.arrayCell = arrayCell
        self.expanded = expanded
    }
}
class CellTableView {
    var nameCell = ""
    var nameImageCell = ""
    
    init(nameCell:String, nameImageCell:String) {
        self.nameCell = nameCell
        self.nameImageCell = nameImageCell
    }
}

class MainVC: UIViewController {

    var arrayCards = Array<Card>(){
        didSet{
            collectionViewCard.reloadData()
        }
    }
    var arrayCurrency = Array<Currency>(){
        didSet{
            collectionViewRates.reloadData()
            pageRates.numberOfPages = arrayCurrency.count
            pageRates.currentPage = 0
        }
    }
    let arrayCurrencyName = ["EUR", "USD"] // курсы валют, которые нужнл загрузить на экран
    var arraysectionTV = [SectionTV]() //секции и ячейки
    
    @IBOutlet weak var collectionViewCard: UICollectionView!
    @IBOutlet weak var collectionViewRates: UICollectionView!
    @IBOutlet weak var activityDownlandRates: UIActivityIndicatorView! //для обозначение загрузки курсов валют
    @IBOutlet weak var activityDownlandCards: UIActivityIndicatorView! //для обозначение загрузки курсов валют
    @IBOutlet weak var tableViewActions: UITableView!
    @IBOutlet weak var pageRates: UIPageControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getClassSection() //Создаем секции и ячейки
        setupCollectionView()
        
        pageRates.numberOfPages = 1
        pageRates.currentPage = 0
        
        getAllRates() // запрашиваем курс валют
        getCards() //запрашиваем данные о карте
        activityDownlandRates.color = .white
        activityDownlandCards.color = .white
    }
}

//MARK: CollectionView
extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func setupCollectionView(){
                
        collectionViewCard.isPagingEnabled = true
        collectionViewRates.isPagingEnabled = true
        
        collectionViewCard.backgroundColor = .clear
        collectionViewRates.backgroundColor = .clear
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.collectionViewCard?.collectionViewLayout = layout
        self.collectionViewRates?.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewRates{
            return arrayCurrency.count
        }
        if collectionView == collectionViewCard{
            print(arrayCards.count)
            return  arrayCards.count
        }
        print("collectionView не определен!!!")
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewCard{
            if let item = collectionViewCard.dequeueReusableCell(withReuseIdentifier: "cellCard", for: indexPath) as? CardCVC{
                if arrayCards.count != 0{
                    let card = arrayCards[indexPath.row]
                    item.amountCard.text = "\(card.balance)"
                    let nameCard = card.name
                    item.nameCard.text = "\(nameCard ?? "NO")"
                    item.numberCard.text = "*\(card.number.prefix(4))"
                }
                return item
            }
        }else if collectionView == collectionViewRates{
            if let item = collectionViewRates.dequeueReusableCell(withReuseIdentifier: "cellRate", for: indexPath) as? RateCVC{
                if arrayCurrency.count != 0{
                    if let buyCurrency = arrayCurrency[indexPath.row].buyCurrency{
                        item.buyCurrency.text = "\(NSString(format:"%.2f", buyCurrency))"
                    }
                    if let saleCurrency = arrayCurrency[indexPath.row].saleCurrency{
                        item.saleCurrency.text = "\(NSString(format:"%.2f", saleCurrency))"
                    }
                    if let rateCBCurrency = arrayCurrency[indexPath.row].rateCBCurrency{
                        item.cbCarrency.text = "\(NSString(format:"%.2f", rateCBCurrency))"
                    }
                    if let nameCurrency = arrayCurrency[indexPath.row].nameCurrency{
                        item.currencyCode.text = nameCurrency
                    }
                }
                return item
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return collectionView.frame.size
    }

    //MARK: Action Page Rates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: self.collectionViewRates.contentOffset, size: self.collectionViewRates.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.collectionViewRates.indexPathForItem(at: visiblePoint) {
            self.pageRates.currentPage = visibleIndexPath.row
        }
    }
}

//MARK: Rates
private extension MainVC{
    
    func getAllRates(){
        for nameRate in arrayCurrencyName{
            getRate(nameCurrency: nameRate)
        }
    }
    
    //получаем курс валюты
    func getExchangeCurrencyRates(currencyName: String, completionHandler: @escaping (Currency?) -> Void){
        NetworkManager.shared().getExchangeCurrencyRates(currency: currencyName) {(success, currency) in
            guard success, currency != nil else{
                print("Не удалось получить курсы getExchangeCurrencyRates")
                completionHandler(nil)
                return
            }
            completionHandler(currency)
            return
        }
    }
    
    //получаем курс ЦБ
    func getABSCurrencyRates(nameCurrencyFrom: String, nameCurrencyTo: String , rateTypeID: Int, completionHandler: @escaping (Double?) -> Void){
        NetworkManager.shared().getABSCurrencyRates(currencyOne: nameCurrencyFrom, currencyTwo: nameCurrencyTo, rateTypeID: rateTypeID) { (success, rateCB) in
            guard success, rateCB != nil else{
                print("Не удалось получить курсы getABSCurrencyRates")
                completionHandler(nil)
                return
            }
            completionHandler(rateCB)
            return
        }
    }
    
    //заполняем данные по курсу
    func getRate(nameCurrency: String){
        self.activityDownlandRates.startAnimating()
        self.activityDownlandRates.isHidden = false
        let currencyR = Currency()
        self.getExchangeCurrencyRates(currencyName: nameCurrency) { [weak self](currency) in
            if currency?.buyCurrency != nil{
                currencyR.buyCurrency = currency!.buyCurrency!
            }
            if currency?.saleCurrency != nil{
                currencyR.saleCurrency = currency!.saleCurrency!
            }
            if currency?.nameCurrency != nil{
                currencyR.nameCurrency = currency?.nameCurrency!
            }else{
                currencyR.nameCurrency = nameCurrency
            }
            
            self!.getABSCurrencyRates(nameCurrencyFrom: "RUB", nameCurrencyTo: nameCurrency, rateTypeID: 95006809) { [weak self](rateCB) in
                if rateCB != nil{
                    currencyR.rateCBCurrency = rateCB!
                }
                self!.activityDownlandRates.stopAnimating()
                self!.activityDownlandRates.isHidden = true
                self!.arrayCurrency.append(currencyR)
            }
        }
    }
}

//MARK: Get Cards
private extension MainVC{
    func getCards(){
        self.activityDownlandCards.startAnimating()
        self.activityDownlandCards.isHidden = false
        NetworkManager.shared().getCardList { [weak self](success, cards) in
            if success{
                guard cards != nil else {
                    return
                }
                self!.activityDownlandCards.stopAnimating()
                self!.activityDownlandCards.isHidden = true
                self!.arrayCards.removeAll()
                self!.arrayCards = cards!
            }else{
                self!.activityDownlandCards.stopAnimating()
                self!.activityDownlandCards.isHidden = true
                print("Не получилось загрузить карты")
            }
        }
    }
}

//MARK: Table View
extension MainVC: UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return arraysectionTV.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arraysectionTV[section].name
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
//        print("Меняем section")
//        view.tintColor = .clear
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.font = UIFont(name: (header.textLabel?.font.fontName)!, size: 13)
//        header.textLabel?.textColor = .black
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraysectionTV[section].arrayCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellActions", for: indexPath) as? ActionCell{
            let cellIndP = arraysectionTV[indexPath.section].arrayCell[indexPath.row]
            cell.nameCell.text = cellIndP.nameCell
            cell.imageCell.image = UIImage(named: cellIndP.nameImageCell)
            cell.imageCell.contentMode = .scaleAspectFit
            return cell
        }
        return UITableViewCell()
    }
    
    //определяем размер сроки в зависимости от нажатия на секцию
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arraysectionTV[indexPath.section].expanded{
            return 35
        }
        return 0
    }
    
    //расстояние между секциями
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpactableHeaderView()
        header.setup(withTitle: arraysectionTV[section].name, section: section, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("id = ", indexPath)
        if indexPath.section == 0{ //Частые действия
            guard let paymentDetailsVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
                return
            }
            let sourceProvider = PaymentOptionCellProvider()
            let destinationProvider = PaymentOptionCellProvider()
            let destinationProviderCardNumber = CardNumberCellProvider()
            let destinationProviderAccountNumber = AccountNumberCellProvider()
            let destinationProviderPhoneNumber = PhoneNumberCellProvider()
            
            paymentDetailsVC.sourceConfigurations = [
                PaymentOptionsPagerItem(provider: sourceProvider, delegate: paymentDetailsVC)
            ]
            switch indexPath.row {
            case 0: //между своими счетами
                paymentDetailsVC.destinationConfigurations = [
                    PaymentOptionsPagerItem(provider: destinationProvider, delegate: paymentDetailsVC)
                ]
                paymentDetailsVC.messageRecipientIsHidden = true // убираем поле комментария при переводе между своими счетами
                let rootVC = tableView.parentContainerViewController()
                rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
                break
            case 1: //клиенту фора банка
                paymentDetailsVC.destinationConfigurations = [
                    PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: paymentDetailsVC),
                    CardNumberPagerItem(provider: destinationProviderCardNumber, delegate: paymentDetailsVC),
                    AccountNumberPagerItem(provider: destinationProviderAccountNumber, delegate: paymentDetailsVC),
                ]
                let rootVC = tableView.parentContainerViewController()
                rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
                break
            default:
                print("Не удалось перейти 0!!!")
            }
        }else if indexPath.section == 1{ //Отделения и банки
            switch indexPath.row {
            case 0: //показать на карте
                print("Переход к картам")
                guard let servicesVC = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ServiceViewController") as? ServicesViewController else {
                    print("Не удалось получить доступ к ServicesViewController")
                    return
                }
                servicesVC.modalPresentationStyle = .fullScreen
                let rootVC = tableView.parentContainerViewController()
                rootVC?.present(servicesVC, animated: true, completion: {
                    servicesVC.buttonBack.isHidden = false
                })
                
            case 1: //список отделений
                guard let listBranchesVC = UIStoryboard(name: "MainScreen", bundle: nil).instantiateViewController(withIdentifier: "BankBranchesList") as? ListBankBranchesVC else {
                    print("Не удалось получить доступ к BankBranchesList")
                    return
                }
                listBranchesVC.modalPresentationStyle = .fullScreen
                let rootVC = tableView.parentContainerViewController()
                rootVC?.present(listBranchesVC, animated: true, completion: nil)
                break
            default:
                print("Не удалось перейти 1!!!")
            }
        }else if indexPath.section == 2{ //связь с банком
            switch indexPath.row {
            case 0:
                let numberPhone = arraysectionTV[indexPath.section].arrayCell[indexPath.row].nameCell
                callNumber(numberPhone)
            case 1:
                let numberPhone = arraysectionTV[indexPath.section].arrayCell[indexPath.row].nameCell
                callNumber(numberPhone)
            case 2:
                let email = arraysectionTV[indexPath.section].arrayCell[indexPath.row].nameCell
                guard let url = URL(string: "mailto:\(email)") else{return}
                
                let alertMail = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let alertActionMail = UIAlertAction(title: "Написать: " + email, style: .default) { (_) in
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
                let alertCancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                alertMail.addAction(alertActionMail)
                alertMail.addAction(alertCancel)
                self.present(alertMail, animated: true, completion: nil)
            default:
                print("Почта")
            }
        }
    }
    
    //MARK: toggleSection
    //обновляем  строки (срабатываем при нажатии на секций)
    func toggleSection(header: ExpactableHeaderView, section: Int) {
        arraysectionTV[section].expanded = !arraysectionTV[section].expanded
        
        self.tableViewActions.beginUpdates()
        for row in 0..<arraysectionTV[section].arrayCell.count{
            tableViewActions.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        }
        self.tableViewActions.endUpdates()
    }
    
    func getClassSection(){
        var arrayCellSection1 = Array<CellTableView>()
        let cell11 = CellTableView(nameCell: "Между своими счетами", nameImageCell: "icon1")
        let cell12 = CellTableView(nameCell: "Клиенту Фора-Банка", nameImageCell: "icon2")
        let cell13 = CellTableView(nameCell: "Мобильная связь", nameImageCell: "icon7")
        arrayCellSection1.append(cell11)
        arrayCellSection1.append(cell12)
        arrayCellSection1.append(cell13)
        
        let sectionOne = SectionTV(name: "Частые действия", arrayCell: arrayCellSection1, expanded: true)
        self.arraysectionTV.append(sectionOne)
        
//        var arrayCellSection2 = Array<CellTableView>()
//        let cell21 = CellTableView(nameCell: "Мой номер", nameImageCell: "bilane")
//        let cell22 = CellTableView(nameCell: "За аренду", nameImageCell: "sberBank")
//        arrayCellSection2.append(cell21)
//        arrayCellSection2.append(cell22)
//
//        let sectionTwo = SectionTV(name: "Шаблоны и автоплатежи", arrayCell: arrayCellSection2, expanded: true)
//        self.arraysectionTV.append(sectionTwo)
        
        var arrayCellSection3 = Array<CellTableView>()
        let cell31 = CellTableView(nameCell: "Показать на карте", nameImageCell: "map")
        let cell32 = CellTableView(nameCell: "Список отделений", nameImageCell: "align-left")
        arrayCellSection3.append(cell31)
        arrayCellSection3.append(cell32)
        
        let sectionThree = SectionTV(name: "Отделения и банки", arrayCell: arrayCellSection3, expanded: true)
        self.arraysectionTV.append(sectionThree)
        
        var arrayCellSection4 = Array<CellTableView>()
        let cell41 = CellTableView(nameCell: "8(800)-100-98-89", nameImageCell: "phone")
        let cell42 = CellTableView(nameCell: "8(495)-775-65-55", nameImageCell: "phone")
        let cell43 = CellTableView(nameCell: "fora-digital@forabank.ru", nameImageCell: "mail")
        arrayCellSection4.append(cell41)
        arrayCellSection4.append(cell42)
        arrayCellSection4.append(cell43)
        
        let sectionFor = SectionTV(name: "Связаться с банком", arrayCell: arrayCellSection4, expanded: true)
        self.arraysectionTV.append(sectionFor)
    }
}
