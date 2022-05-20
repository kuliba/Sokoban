//
//  DepositInfoViewController.swift
//  ForaBank
//
//  Created by Mikhail on 14.12.2021.
//

import UIKit

class DepositInfoViewController: UIViewController {

    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        view.layer.cornerRadius = 44
        view.clipsToBounds = true
        view.setDimensions(height: 88, width: 88)
        
        let image = UIImage(named: "info")
        let imView = UIImageView(image: image)
        imView.tintColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1)
        
        view.addSubview(imView)
        imView.setDimensions(height: 40, width: 40)
        imView.center(inView: view)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(text: "Ваш потенциальный доход рассчитан с учетом капитализации процентов за весь срок действия вклада",
                            font: UIFont(name: "Inter-SemiBold", size: 16))
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(closeMenu))
        
        self.navigationItem.rightBarButtonItem = button
        view.backgroundColor = .white
        setupUI()
        
    }
    
    private func setupUI() {
        view.addSubview(topView)
        topView.centerX(inView: view,
                        topAnchor: view.safeAreaLayoutGuide.topAnchor,
                        paddingTop: 10)
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view,
                           topAnchor: topView.bottomAnchor,
                           paddingTop: 24)
        titleLabel.anchor(left: view.leftAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor,
                          paddingLeft: 20,
                          paddingBottom: 20,
                          paddingRight: 20)
    }
    
    @objc func closeMenu() {
        self.dismiss(animated: true, completion: nil)
    }

}
