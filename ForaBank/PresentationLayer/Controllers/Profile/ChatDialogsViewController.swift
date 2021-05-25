//
//  ChatDialogsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 27/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit


class ChatDialogsViewController: UIViewController, EPPickerDelegate {

    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
//    @IBOutlet weak var backButton: UIButton!
    private var users = [ObjectUser]()
    private var conversations = [ObjectConversation]()
    private let manager = ConversationManager()
    private let userManager = UserManager()
    private var currentUser: ObjectUser?
    let refreshControl = UIRefreshControl()
    let dialogCellId = "DialogCell"
    var fullName: String?
    let userID = UserManager().currentUserID() ?? ""
    var data_ = [
        Friend(name: "Техническая поддержка", message: "Последнее сообщение"),
        Friend(name: "Андрей Савушкин", message: "Понял, жду."),
        Friend(name: "Павел Герасимчук", message: "Вы: Тогда до среды."),
        Friend(name: "Анна Ахматова", message: "Ну ладно, еще увидимся на выходных значит."),
        Friend(name: "Елисей Терешков", message: "Вы: Хорошо отдохнули."),
        Friend(name: "Максим Ложкин", message: "Ок, сделаю."),
        Friend(name: "Илья Третьяков", message: "Всё пришло")
    ]

    @IBOutlet weak var addFriend: UIButton!

    @IBAction func addFriendAction(_ sender: UIButton) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:false, subtitleCellType: SubtitleCellValue.phoneNumber)
        contactPickerScene.navigationController?.navigationBar.backgroundColor = UIColor(hexFromString: "EA4644")!

        
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        navigationController.navigationBar.backgroundColor = UIColor(hexFromString: "EA4644")!
        navigationController.topViewController?.title = "Контакты"
        navigationController.title = "Контакты"
        navigationController.navigationBar.tintColor = .white
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact){
        let strSearch = "\(String(cleanNumber(number: contact.phoneNumbers[0].phoneNumber) ?? "nil"))@forabank.ru"
                let cleanNumeber = cleanNumber(number: strSearch)
                var confirmNumber = false
                for number in users{
                    if cleanNumeber == number.email {
                        contactsPreviewController(didSelect: number)
                        confirmNumber = true
                    }
        //            else {
        //                let alert = UIAlertController(title: "Такого пользователя не существует", message: "Уточните номер телефона", preferredStyle:  .alert)
        //                alert.addAction(.init(title: "Ок", style: .default, handler: nil))
        //                present(alert, animated: true, completion: nil)
        //            }
                }
                if confirmNumber == false{
                                    let alert = UIAlertController(title: "Такого пользователя не существует", message: "Уточните номер телефона", preferredStyle:  .alert)
                                    alert.addAction(.init(title: "Ок", style: .default, handler: nil))
                                    present(alert, animated: true, completion: nil)
                        
                }
    }
    func contactsPreviewController(didSelect user: ObjectUser) {
        guard let currentID = userManager.currentUserID() else { return }
          let vc:ChatMessagesViewController = UIStoryboard(name: "SupportChat", bundle: nil).instantiateViewController(withIdentifier: "ChatMessagesViewController") as! ChatMessagesViewController
          if let conversation = conversations.filter({$0.userIDs.contains(user.id)}).first {
          vc.conversation = conversation
          show(vc, sender: self)
          return
        }
        let conversation = ObjectConversation()
        conversation.userIDs.append(contentsOf: [currentID, user.id])
        conversation.isRead = [currentID: true, user.id: true]
        vc.conversation = conversation
        show(vc, sender: self)
      }
      
    
    // MARK: - Actions
//
//    @IBAction func backButtonCLicked(_ sender: Any) {
//        view.endEditing(true)
//        self.navigationController?.popViewController(animated: true)
//        if navigationController == nil {
//            dismiss(animated: true, completion: nil)
//        }
//    }

    // MARK: - Lifecycle


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        setTableViewDelegateAndDataSource()
        addRefreshControl()
        registerNibCell()
        setSearchView()
        fetchConversations()
        self.userManager.currentUserData({ (currentUser) in
            self.currentUser = currentUser
            currentUser?.name = self.fullName
            self.userManager.update(user: currentUser ?? ObjectUser.init()) { (_) in}})

//        // Prepare back button for animation
//        backButton.alpha = 0
//        backButton.frame.origin.x += 5
    }


    

    
    func fetchConversations() {
      manager.currentConversations {[weak self] conversations in
        self?.conversations = conversations.sorted(by: {$0.timestamp > $1.timestamp})
        self?.tableView.reloadData()
      }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = userManager.currentUserID() else { return }
        userManager.contacts {[weak self] results in
          self?.users = results.filter({$0.id != id})
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        refreshData()
        NetworkManager.shared().getProfile { (success, profile, error) in
                  if success{
                    self.fullName = String("\(profile?.firstName ?? "") \(profile?.patronymic ?? "") \(profile?.lastName ?? ""   )")
                  } else {
                      print("Error in ObjectUser in Profile service")
                  }
              }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        animateBackButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? ChatMessagesViewController,
//            let index = sender as? Int {
//            vc.dialogName = data_[index].name
//        }
//    }
}

// MARK: - UITableView DataSource and Delegate
extension ChatDialogsViewController: UITableViewDataSource, UITableViewDelegate {

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let header = tableView.dequeueReusableCell(withIdentifier: dialogCellId) as? DialogCell else {
//                 fatalError()
//             }
//        header.messageLabel.text = ""
//        header.timeLabel.text = ""
//        header.userNameLabel.text = "Техническая поддержка"
//        header.userPicImageView.image = UIImage(named: "foralogotype")
//        return header
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 1
        } else {
        return conversations.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: dialogCellId, for: indexPath) as? DialogCell else {
            fatalError()
        }
        if indexPath.section == 1{
            cell.userNameLabel.text = "Техническая поддержка"
            cell.userPicImageView.image = UIImage(named: "foralogotype")
            cell.timeLabel.text = ""
            cell.messageLabel.text = ""
            cell.isReaded.isHidden = true
            
        } else {
        if indexPath.row == conversations.endIndex {
            // Remove last separator
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        }
//        if indexPath.row == 0{
//            cell.userPicImageView.image = UIImage(named: "foralogotype")
//
//        } else {
        cell.userPicImageView.image = UIImage(named: "question")
        cell.set(conversations[indexPath.row])
        

//        }
//        cell.userNameLabel.text = conversation[indexPath.row].name
//        cell.messageLabel.attributedText = {
//            let string = data_[indexPath.row].message
//            let font = UIFont(name: "Roboto-Light", size: 14) ?? UIFont.systemFont(ofSize: 14)
//            let attributes = [NSAttributedString.Key.font: font]
//            let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
//
//            let icon = NSTextAttachment()
//            let iconImage = UIImage(named: "icon_read")
//            icon.image = iconImage
//            let iconSize = CGRect(x: 0, y: 0, width: 13, height: 11)
//            icon.bounds = iconSize
//
//            // - TODO: Sample data. Remove once data handler is ready.
//            if indexPath.row == 1 || indexPath.row == 3 {
//                attributedString.append(NSAttributedString(attachment: icon))
//            }
//
//            return attributedString
//        }()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChatMessagesViewController") as! ChatMessagesViewController
        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
        if indexPath.section == 1{
            vc.dialogName = "Техническая поддержка"
        } else {
            vc.conversation = conversations[indexPath.row]
            manager.markAsRead(conversations[indexPath.row])
        }
        self.present(navController, animated:true, completion: nil)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .destructive, title: "Удалить") { [weak self] action, indexPath in
            self?.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        return [deleteRowAction]
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

//    func animateBackButton() {
//        UIView.animate(
//            withDuration: 0.25,
//            delay: 0,
//            options: [.allowUserInteraction],
//            animations: {
//                self.backButton.alpha = 1
//                self.backButton.frame.origin.x -= 5
//            },
//            completion: { _ in
//
//            })
//    }

    func setSearchView() {
        guard let searchCell = UINib(nibName: "SearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? UIView else {
                return
        }
        let searchView = UIView(frame: searchCell.frame)
        searchView.addSubview(searchCell)
        tableView.tableHeaderView = searchView
    }
}

