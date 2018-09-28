//
//  ChatDialogsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 27/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

struct Friend {
   let name: String
   let message: String
}

class ChatDialogsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: ChatDialogsTableView!
    @IBOutlet weak var backButton: UIButton!
    
    let refreshControl = UIRefreshControl()
    let dialogCellId = "DialogCell"
    
    var data_ = [
        Friend(name: "Андрей Савушкин", message: "Понял, жду."),
        Friend(name: "Павел Герасимчук", message: "Вы: Тогда до среды."),
        Friend(name: "Анна Ахматова", message: "Ну ладно, еще увидимся на выходных значит."),
        Friend(name:  "Елисей Терешков", message: "Вы: Хорошо отдохнули."),
        Friend(name: "Максим Ложкин", message: "Ок, сделаю."),
        Friend(name: "Илья Третьяков", message: "Всё пришло")
    ]
    
    // MARK: - Actions
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewDelegateAndDataSource()
        addRefreshControl()
        registerNibCell()
        
        // Prepare button for animation
        backButton.alpha = 0
        backButton.frame.origin.x += 5

        // Add search text field
        if let searchCell = UINib(nibName: "SearchCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView {
            let searchView = UIView(frame: searchCell.frame)
            searchView.addSubview(searchCell)
            tableView.tableHeaderView = searchView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatMessagesViewController,
            let index = sender as? Int {
            vc.dialogName  = data_[index].name
        }
    }
}

// MARK: - UITableView DataSource and Delegate
extension ChatDialogsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: dialogCellId, for: indexPath) as? DialogCell else {
            fatalError()
        }
        
        // Remove last separator
        if indexPath.row == data_.endIndex {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        }
        
        cell.userPicImageView.image = UIImage(named: "image_friend_\(indexPath.row)")
        cell.userNameLabel.text = data_[indexPath.row].name
        cell.messageLabel.attributedText = {
            let string = data_[indexPath.row].message
            let font = UIFont(name: "Roboto-Light", size: 14) ?? UIFont.systemFont(ofSize: 14)
            let attributes = [NSAttributedString.Key.font: font]
            let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
            
            let icon = NSTextAttachment()
            let iconImage = UIImage(named: "icon_read")
            icon.image = iconImage
            let iconSize = CGRect(x: 0, y: 0, width: 13, height: 11)
            icon.bounds = iconSize
            
            // - TODO: Sample data. Remove once data handler is ready.
            if indexPath.row == 1 || indexPath.row == 3 {
                attributedString.append(NSAttributedString(attachment: icon))
            }
            
            return attributedString
        }()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatMessagesViewController", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { action, indexPath in
            self.data_.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
    }
}

// MARK: - Private methods
private extension ChatDialogsViewController {
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func registerNibCell() {        
        let nibCell = UINib(nibName: dialogCellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: dialogCellId)
    }
    
    func addRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        
    }
    
    func animateBackButton() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.backButton.alpha = 1
                self.backButton.frame.origin.x -= 5
        },
            completion: { _ in
                
        })
    }
}
