//
//  CardListView.swift
//  ForaBank
//
//  Created by Mikhail on 22.06.2021.
//

import UIKit

class CardListView: UIView {
    
    //MARK: - Property
    var cardList = [Datum]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    

    func commonInit() {
//        self.viewModel = viewModel
//        textField.addTarget(self, action: #selector(setupValue), for: .editingChanged)
//        textField.delegate = self
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
}


extension CardListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        cell.backgroundColor = .red
        return cell
    }
    
    
}

extension CardListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 50, height: 50)
    }
    
}

extension CardListView: UICollectionViewDelegate {
    
}



class CardCell: UICollectionViewCell {
    
    //MARK: - Properties
    var card: Datum? {
        didSet { configure() }
    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 24, width: 24)
        return imageView
    }()
    
    private let maskCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11 )
        label.text = ""
        return label
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11 )
        label.text = ""
        return label
    }()

    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func hendleShareTapped() {
        print(#function)
    }
    
    //MARK: - Helpers
    func configure() {
        guard let card = card else { return }
        
        let viewModel = CardViewModel(card: card)

        balanceLabel.text = viewModel.balance
        maskCardLabel.text = viewModel.maskedcardNumber
        logoImageView.image = viewModel.logoImage
    }
    
    func setupUI() {
        addSubview(logoImageView)
        addSubview(maskCardLabel)
        addSubview(balanceLabel)
        
        logoImageView.anchor(top: self.topAnchor)
        
    }
    
}


struct CardViewModel {
    
    let card: Datum
    
    var cardNumber: String? {
        return card.original?.number
    }
    
    var balance: String {
        let cardBal: Double = card.original?.balance ?? 0
        return cardBal.currencyFormatter()
    }
    
    var maskedcardNumber: String? {
        return "  *\(cardNumber?.suffix(4) ?? "")"
    }
    
    var logoImage: UIImage {
        let firstSimb = card.original?.number
        switch firstSimb {
        case "1":
            return #imageLiteral(resourceName: "mir-colored")
        case "4":
            return #imageLiteral(resourceName: "card_visa_logo")
        case "5":
            return #imageLiteral(resourceName: "card_mastercard_logo")
        default:
            return UIImage()
        }
    }
    
    init(card: Datum) {
        self.card = card
    }
    
}
