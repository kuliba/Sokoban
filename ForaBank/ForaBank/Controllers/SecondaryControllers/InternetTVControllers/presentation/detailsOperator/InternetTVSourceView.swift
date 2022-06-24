import UIKit

class InternetTVSourceView: UITableViewHeaderFooterView {
    
    let model = Model.shared
    var stackView = UIStackView(arrangedSubviews: [])
    var cardFromField = CardChooseView()
    var cardListView = CardsScrollView(onlyMy: false, deleteDeposit: true, loadProducts: false)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupUI()
        configureContents()
        self.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()

        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.isUserInteractionEnabled = true
        
        cardListView.isHidden = false
        setupActions()
    }

    func setupActions() {
        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                
                let products = self.model.products.value.values.flatMap({ $0 }).map { $0.userAllProducts() }
                
                products.forEach({ card in
                    if card.id == cardId {
                        self.cardFromField.model = card
    
                        self.hideView(self.cardListView, needHide: true)
                    }
                })
            }
        }
        
    }
    
    
    //MARK: - Animation
    func openOrHideView(_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if view.isHidden == true {
                    view.isHidden = false
                    view.alpha = 1
                } else {
                    view.isHidden = true
                    view.alpha = 0
                }
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    func hideView(_ view: UIView, needHide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if view.isHidden == !needHide {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.stackView.layoutIfNeeded()
                }
            }
        }
    }
    
    func configureContents() {
        contentView.backgroundColor = .clear
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
}
