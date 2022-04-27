//
//  SettingsPhotoViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.04.2022.
//

import Foundation
import UIKit

class SettingsPhotoViewController: UIViewController {

    let cellReuse = "SettingPhotoCell"
    var itemIsSelect: ((String) -> Void)?
    var elements = ["Сделать фото", "Выбрать из галереи"]
    
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 3))
        imageView.contentMode = .scaleToFill
        let image = UIImage(named: "Rectangle 85")
        imageView.image = image
        navigationItem.titleView = imageView
        view.backgroundColor = .white
        setupTableView()
        
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 20,
            paddingBottom: 20, paddingRight: 20)
        tableView.register(UINib(nibName: cellReuse, bundle: nil), forCellReuseIdentifier: cellReuse)
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
    }
    
    
}

extension SettingsPhotoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuse, for: indexPath) as? SettingPhotoCell else { return UITableViewCell() }

        cell.titleLabel.text = elements[indexPath.row]
        cell.currencyView.image = UIImage(named: elements[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
}

extension SettingsPhotoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            
            self.itemIsSelect?(self.elements[indexPath.row])
        }
    }
}
