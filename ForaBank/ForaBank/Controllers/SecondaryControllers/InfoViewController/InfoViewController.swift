//
//  InfoViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 18.05.2022.
//

import UIKit

class InfoViewController: UIViewController {
    
    let titleLabel = UILabel(text: "", font: .systemFont(ofSize: 16))
    let image = UIImageView(image: .init(named: "alert-circle"))
    var depositType: DepositType
    
    enum DepositType: CustomStringConvertible, Equatable {
        
        case fullWithAmount(String)
        case full
        case beforeClosing
        
        var description : String {
            switch self {
            case .fullWithAmount(let title): return title
            case .full: return "Вы можете снять полную сумму вклада и выплаченных процентов"
            case .beforeClosing: return "Сумма расчитана автоматически с учетом условий по вашему вкладу"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    
    init(depositType: DepositType) {
        self.depositType = depositType
        self.titleLabel.text = depositType.description
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        view.addSubview(image)
        view.addSubview(titleLabel)
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16)
    }
    
    fileprivate func setupConstraints() {
        
        image.centerX(inView: view)
        titleLabel.anchor(top: image.bottomAnchor, left: view.leftAnchor,  bottom: view.bottomAnchor, right: view.rightAnchor,
                          paddingTop: 24, paddingLeft: 20, paddingBottom: 80, paddingRight: 20)
        
    }
}
