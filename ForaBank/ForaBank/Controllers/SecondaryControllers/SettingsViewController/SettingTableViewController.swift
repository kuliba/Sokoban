//
//  SettingTableViewController.swift
//  ForaBank
//
//  Created by Mikhail on 16.09.2021.
//

import UIKit
import RealmSwift
import LocalAuthentication

protocol SettingTableViewControllerDelegate: AnyObject {
    func goLoginCardEntry()
}


class SettingTableViewController: UITableViewController {
    

    var delegate: SettingTableViewControllerDelegate?
    
    let kHeaderViewHeight: CGFloat = 140
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var faceId: UISwitch!
    
    
    var imageView = UIImageView()
    
    private var tableHeaderView: UIView? {
        //button
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.layer.cornerRadius = 32 / 2
        button.clipsToBounds = true
        button.setImage(UIImage(named: "edit-2"), for: .normal)
        button.addTarget(self, action: #selector(changeImage), for: .touchUpInside)
        
        //imageView
        let userPhoto = loadImageFromDocumentDirectory(fileName: "userPhoto")
        if userPhoto != nil {
            imageView.image = userPhoto
        } else {
            imageView.image = UIImage(named: "ProfileImage")
        }
        imageView.backgroundColor = UIColor.clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 96 / 2
        imageView.setDimensions(height: 96, width: 96)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: kHeaderViewHeight))
        headerView.backgroundColor = UIColor.white
        headerView.addSubview(imageView)
        headerView.addSubview(button)
        
        imageView.centerX(inView: headerView,
                          topAnchor: headerView.topAnchor, paddingTop: 16)
        button.anchor(top: imageView.topAnchor, right: imageView.rightAnchor,
                      width: 32, height: 32)
        
        return headerView
    }
    
    
    let context = LAContext()
    var error: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        tableView.tableHeaderView = tableHeaderView
        emailLabel.text = ""
        loadConfig()
       
        tableView.isUserInteractionEnabled = true
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self?.faceId.isOn = true
                    } else {
                        self?.faceId.isOn = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
             self.faceId.isOn = false
            }
        }
        
    }

    private func loadConfig() {
        showActivity()
        NetworkManager<GetUserSettingDecodableModel>.addRequest(.getUserSettings, [:], [:]) { model, error in
            if error != nil {
                self.dismissActivity()
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                if let model = model {
                    if model.statusCode == 0 {
                        DispatchQueue.main.async {
                            model.data?.userSettingList?.forEach({ setting in
                                if setting.sysName == "DisablePush" {
                                    self.pushSwitch.isOn = setting.value == "1" ? false : true
                                }
                            })
                        }
                    }
                }
                self.getUserAccount { [weak self] contractList, error in
                    self?.dismissActivity()
                    if error != nil {
                        self?.showAlert(with: "Ошибка", and: error!)
                    } else {
                        if let contractList = contractList {
                            DispatchQueue.main.async {
                                let mask = StringMask(mask: "+0 (000) 000-00-00")
                                let number = mask.mask(string: contractList.phone)
                                self?.phoneLabel.text = number
                                if let userName = UserDefaults.standard.object(forKey: "userName") as? String {
                                    self?.nameLabel.text = userName
                                } else {
                                    self?.nameLabel.text = contractList.firstName
                                }
                                if let userName = contractList.email {
                                self?.emailLabel.text = userName
                                } else {
                                    self?.emailLabel.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Actions
    
    @objc func changeImage() {
        let controller = SettingsPhotoViewController()
        controller.itemIsSelect = { [weak self] item in
            
            switch item {
            case "Сделать фото":
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.allowsEditing = true
                vc.delegate = self
                self?.present(vc, animated: true)
            case "Выбрать из галереи":
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.navigationController?.navigationBar.tintColor = .black
                self?.present(imagePickerController, animated: true, completion: nil)
            default:
                print()
            }
            
        }
        
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        self.present(navController, animated: true)
        
    }
    
    
    @IBAction func pushSwitchChange(_ sender: UISwitch) {
        let value = sender.isOn ? "0" : "1"
        let body = ["settingSysName": "DisablePush",
                    "settingValue": value] as [String : AnyObject]
        NetworkManager<SetUserSettingDecodableModel>.addRequest(.setUserSetting, [:], body) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            
        }
    }
    
    @IBAction func sbpCellAction(_ sender: Any) {
    
        self.showActivity()
        getFastPaymentContractList { [weak self] contractList, error in
            self?.dismissActivity()
            if error != nil {
                self?.showAlert(with: "Ошибка", and: error!)
            } else {
                DispatchQueue.main.async {
                    let vc = MeToMeSettingViewController()
                    if contractList != nil {
                        vc.model = contractList
                    } else {
                        vc.model = []
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    
    //MARK: - API
    @IBAction func logout(_ sender: Any) {
        showAlertWithCancel(with: "Выход", and: "Вы действительно хотите выйте из учетной записи?") {
            NetworkManager<LogoutDecodableModel>.addRequest(.logout, [:], [:]) { _,_  in
                DispatchQueue.main.async {
                    self.cleanAllData()
                    Model.shared.action.send(ModelAction.LoggedOut())
                    self.delegate?.goLoginCardEntry()
                }
            }
        }
    }
    
    @IBAction func showChangeNameAlertButton(_ sender: Any) {
        self.showInputDialog(title: "Имя", subtitle: "Как к вам обращаться?", actionTitle: "Да", cancelTitle: "Отмена", inputText: self.nameLabel.text, inputPlaceholder: "Введите Имя", inputKeyboardType: .default) { _ in } actionHandler: { text in
            if text != nil {
            UserDefaults.standard.set(text, forKey: "userName")
            self.nameLabel.text = text
            }
        }

    }
    @IBAction func faceIdAction(_ sender: UISwitch) {
        
        self.showAlertWithCancel(with: "Для активации Face ID необходимо выполнить переход в настройки устройства.", and: "") {
            if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                if UIApplication.shared.canOpenURL(appSettings) {
                  UIApplication.shared.open(appSettings)
                }
              }
        }

    }
    @IBAction func faceIdSwitch(_ sender: Any) {
        
    }
    
    @IBAction func showPhoneAlert(_ sender: Any) {
        self.showAlert(with: "Телефон", and: "для смены номера обратитесь в колл-центр или отделение банка")
    }
    
    private func cleanAllData() {
        UserDefaults.standard.setValue(false, forKey: "UserIsRegister")
        
        //TODO: - Написать очистку данных после выхода из приложения
        ClearRealm.clear()
        
        AppDelegate.shared.isAuth = false
    }
    
    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                completion(nil, model.errorMessage)
            }
        }
        
    }
    
    func getUserAccount(_ completion: @escaping (_ model: ClintInfoModelData? ,_ error: String?) -> Void) {
        NetworkManager<ClintInfoModel>.addRequest(.getClientInfo, [:], [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                completion(nil, model.errorMessage)
            }
        }
        
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewForHeader = UIView()
        viewForHeader.backgroundColor = .white
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular_Bold", size: 20)
        label.textColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        viewForHeader.addSubview(label)
        label.centerY(inView: viewForHeader, leftAnchor: viewForHeader.leftAnchor, paddingLeft: 16)
        switch section {
        case 0:
            label.text = "Мои данные"
//        case 1:
//            label.text = "Документы"
        case 1:
            label.text = "Платежи и переводы"
        case 2:
            label.text = "Безопасность"
        default:
            label.text = ""
        }
        return viewForHeader
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
        saveImageInDocumentDirectory(image: image, fileName: "userPhoto")
        
    }
    
    func saveImageInDocumentDirectory(image: UIImage, fileName: String) {
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.pngData() {
            try? imageData.write(to: fileURL, options: .atomic)
            
        }
    }
    
    func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
    }
    
}


extension SettingTableViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 200
        return presenter
    }
}

