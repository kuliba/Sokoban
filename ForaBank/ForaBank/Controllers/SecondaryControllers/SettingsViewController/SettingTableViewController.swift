//
//  SettingTableViewController.swift
//  ForaBank
//
//  Created by Mikhail on 16.09.2021.
//

import UIKit

class SettingTableViewController: UITableViewController {

    let kHeaderViewHeight: CGFloat = 140
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var pushSwitch: UISwitch!
    
    
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
        imageView.image = UIImage(named: "ProfileImage")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        tableView.tableHeaderView = tableHeaderView
        nameLabel.text = ""
        phoneLabel.text = ""
        emailLabel.text = ""
    }

    //MARK: - Actions
    
    @objc func changeImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.navigationController?.navigationBar.tintColor = .black
        present(imagePickerController, animated: true, completion: nil)

    }
    
    
    @IBAction func pushSwitchChange(_ sender: UISwitch) {
        let value = sender.isOn ? "0" : "1"
        let body = ["settingSysName": "DisablePush",
                    "settingValue": value] as [String : AnyObject]
        NetworkManager<SetUserSettingDecodableModel>.addRequest(.setUserSetting, [:], body) { model, error in
            
            
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
        NetworkManager<LogoutDecodableModel>.addRequest(.logout, [:], [:]) { _,_  in
            print("Logout :", "Вышли из приложения")
            DispatchQueue.main.async {
                UserDefaults.standard.setValue(false, forKey: "UserIsRegister")
                let navVC = UINavigationController(rootViewController: LoginCardEntryViewController())
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true, completion: nil)
            }
            
        }
    }
    
    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(nil, error)
            }
            guard let model = model else { return }
            print("DEBUG: fastPaymentContractFindList", model)
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                DispatchQueue.main.async {
                if model.errorMessage == "Пользователь не авторизован"{
                    AppLocker.present(with: .validate)
                }
                }
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
        case 1:
            label.text = "Платежи и переводы"
        case 2:
            label.text = "Безопастность"
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
    }
}

