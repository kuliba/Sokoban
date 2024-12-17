//
//  CustomCardListViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.07.2021.
//

import UIKit

class CardTableCell: UITableViewCell {
    
    let cardView = CardChooseView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        comonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comonInit()
    }
    
    func comonInit() {
        self.addSubview(cardView)
        cardView.centerY(inView: self)
        cardView.anchor(left: self.leftAnchor, right: self.rightAnchor)
        cardView.titleLabel.text = ""
        cardView.choseButton?.isHidden = true
        cardView.backgroundColor = .clear
    }
}


class AllCardListViewController: UITableViewController {
    
    let cellIdentifier = "CardTableCell"
    let saveIdentifier = "SaveCell"
    var onlyCard = true
    var withTemplate = true
    
    let model = Model.shared
    
    var cardModel: [UserAllCardsModel] = [] {
        didSet { DispatchQueue.main.async {
            self.tableView.reloadData() } } }
    
    var saveCardModel: [GetProductTemplateDatum] = [] {
        didSet { DispatchQueue.main.async {
            self.tableView.reloadData() } } }

    var didCardTapped: ((UserAllCardsModel) -> Void)?
    var didTemplateTapped: ((GetProductTemplateDatum) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        navigationItem.title = "Выберите карту"
        addCloseButton()
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.register(CardTableCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 20)
        
        var products: [UserAllCardsModel] = []
        var types: [ProductType] = [.card]
        if !onlyCard {
            types.append(.account)
        }
        types.forEach { type in
            products.append(contentsOf: self.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
        }
        
        let clientId = Model.shared.clientInfo.value?.id
        cardModel = products.filter({$0.ownerID == clientId})
        
        if withTemplate {
            getProductTemplate()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if saveCardModel.isEmpty {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return cardModel.count
        default:
            return saveCardModel.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        let titleLabel = UILabel(text: "Свои", font: .systemFont(ofSize: 14), color: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        if section == 1 {
            titleLabel.text = "Сохраненные"
        }
        view.addSubview(titleLabel)
        titleLabel.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 20)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CardTableCell
            cell.cardView.getUImage = { self.model.images.value[$0]?.uiImage }
            cell.cardView.model = cardModel[indexPath.row]
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CardTableCell
            cell.cardView.tempCardModel = saveCardModel[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            let model = cardModel[indexPath.row]
            didCardTapped?(model)
        default:
            let model = saveCardModel[indexPath.row]
            didTemplateTapped?(model)
        }
    }
    
    //MARK: - API
    
    private func getProductTemplate() {
        NetworkManager<GetProductTemplateListDecodableModel>.addRequest(.getProductTemplateList, [:], [:]) { model, error in
            if error != nil {
                guard let error = error else { return }
//                completion(nil, error)
            } else {
                guard let model = model else { return }
                guard let statusCode = model.statusCode else { return }
                if statusCode == 0 {
                    guard let tempList = model.data else { return }
                    self.saveCardModel = tempList
                } else {
                    let error = model.errorMessage ?? "nil"
//                    completion(nil, error)
                }
            }
        }
    }
    
    
}
