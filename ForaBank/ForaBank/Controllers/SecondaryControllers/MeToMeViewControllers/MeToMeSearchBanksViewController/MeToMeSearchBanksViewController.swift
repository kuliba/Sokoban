//
//  MeToMeSearchBanksViewController.swift
//  ForaBank
//
//  Created by Mikhail on 19.08.2021.
//

import UIKit
import IQKeyboardManagerSwift

class MeToMeSearchBanksViewController: UIViewController {
    
    weak var rootVC: MeToMeSettingViewController?
    
    var allBanks = [BankFullInfoList]()
    var banks = [BankFullInfoList]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var selectedBanks = [BankFullInfoList]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    let searchTextField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название банка"
        return textField
    }()
    
    var didBankTapped: ((BankFullInfoList) -> Void)?
    
    let topLabel: UILabel = {
        let label = UILabel(text: "Выберите банк(и), из которого будет разрешено запрашивать переводы",
                            font: UIFont(name: "Inter-Regular", size: 12),
                            color: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        label.numberOfLines = 2
        return label
    }()
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        let nib = UINib(nibName: "BankTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BankTableViewCell.reuseId)
        return tableView
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(title: "Сохранить")
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return button
    }()
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        setupUI()
        suggestBank("") { bankList, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error ?? "")
            } else {
                guard let bankList = bankList else { return }
                self.banks = bankList
                self.allBanks = bankList
                self.getClientConsent { consentList, error in
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error ?? "")
                    } else {
                        var selected = [BankFullInfoList]()
                        consentList?.forEach({ consent in
                            self.allBanks.forEach { bank in
                                if bank.memberID == consent.bankId {
                                    selected.append(bank)
                                }
                            }
                        })
                        self.selectedBanks = selected
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    //MARK: - Setup UI
    func setupUI() {
        view.backgroundColor = .white
        setupNavigationBar()

        let bottomView = UIView()
        bottomView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 0.82)
        
        let logo = UIImageView(image: UIImage(named: "sfpBig"))
        bottomView.addSubview(logo)
        bottomView.addSubview(saveButton)
        
        logo.centerX(inView: bottomView)
        logo.anchor(bottom: bottomView.bottomAnchor, paddingBottom: 14)
        saveButton.anchor(top: bottomView.topAnchor,
                          left: bottomView.leftAnchor,
                          right: bottomView.rightAnchor,
                          paddingTop: 14, paddingLeft: 20,
                          paddingRight: 20, height: 48)
        
        view.addSubview(topLabel)
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        view.addSubview(bottomView)
        
        bottomView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                          right: view.rightAnchor, height: 136)
        
        topLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                        left: view.leftAnchor, right: view.rightAnchor,
                        paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        
        searchTextField.anchor(top: topLabel.bottomAnchor,
                             left: view.leftAnchor, right: view.rightAnchor,
                             paddingTop: 20, paddingLeft: 20,
                             paddingRight: 20, height: 44)
        
        tableView.anchor(top: searchTextField.bottomAnchor, left: view.leftAnchor,
                         bottom: view.bottomAnchor, right: view.rightAnchor,
                         paddingTop: 20)
        
    }
    
    
    
    private func setupNavigationBar() {
        let color = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        let label = UILabel()
        label.textColor = color
//        label.font = UIFont(name: "Inter-Regular", size: 18)
        label.font = UIFont(name: "Inter-Regular_SemiBold", size: 18)
        label.text = "Выберите банки"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true
        
        let button = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action:  #selector(backAction))
        
        navigationItem.rightBarButtonItem = button
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: color, .font: UIFont(name: "Inter-Regular", size: 14)!], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: color, .font: UIFont(name: "Inter-Regular", size: 14)!], for: .highlighted)
    }
    
    //MARK: - Actions
    @objc func backAction(){
        dismiss(animated: true, completion: nil)
//        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveAction(){
        var bankList: [String] = []
        selectedBanks.forEach { bank in
            bankList.append(bank.memberID ?? "")
        }

        let body = ["bankIdList" : bankList] as [String: AnyObject]
        self.showActivity()
        NetworkManager<ChangeClientConsentMe2MePullDecodableModel>.addRequest(.changeClientConsentMe2MePull, [:], body) { [unowned self] model, error in
            DispatchQueue.main.async {
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                } else {
                    
                    let nameBanksSelected = self.selectedBanks
                        .compactMap { $0.rusName == nil ? $0.fullName : $0.rusName }
                    self.rootVC?.banksView.banksName = nameBanksSelected
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - API
    func suggestBank(_ bic: String, completion: @escaping (_ bankList: [BankFullInfoList]?, _ error: String?) -> Void ) {
        showActivity()
        
        self.dismissActivity()
                
        let data = Model.shared.dictionaryFullBankInfoList()
        var filterBank: [BankFullInfoList] = []
        data.forEach({ bank in
            let fullBankInfoItem = bank.fullBankInfoList
            if fullBankInfoItem.senderList?.contains("ME2MEPULL") ?? false
                && fullBankInfoItem.receiverList?.contains("ME2MEPULL") ?? false {
                filterBank.append(fullBankInfoItem)
            }
        })
        var list = filterBank.sorted(by: {$0.rusName ?? "" < $1.rusName ?? ""})
        //#if RELEASE
        list.forEach { bank in
            if bank.memberID == BankID.foraBankID.rawValue {
                if let index = list.firstIndex(where: {$0.memberID == bank.memberID}) {
                    list.remove(at: index)
                }
            }
        }
        //#endif
        completion(list, nil)
        
    }
    
    func getClientConsent(completion: @escaping (_ bankList: [ConsentList]?, _ error: String?) -> Void) {
        showActivity()
        NetworkManager<GetClientConsentMe2MePullDecodableModel>.addRequest(.getClientConsentMe2MePull, [:], [:]) { [weak self] model, error in
            self?.dismissActivity()
            if error != nil {
                guard let error = error else { return }
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                completion(data.consentList ?? [], nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }
    }
    
    
    //MARK: - Helpers
    private func chekBank(bank: BankFullInfoList, selected banks: [BankFullInfoList]) -> Bool {
        var result = false
        banks.forEach { eachBank in
            if eachBank.bic == bank.bic {
                result = true
            }
        }
        return result
    }
    
}

//MARK: - UITableView Delegate DataSource
extension MeToMeSearchBanksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BankTableViewCell.reuseId, for: indexPath) as! BankTableViewCell
        let bank = banks[indexPath.item]
        cell.configure(with: bank, and: indexPath)
        if chekBank(bank: bank, selected: selectedBanks) {
            cell.chekboxImgeView.image = UIImage(named: "Checkbox_active")
        } else {
            cell.chekboxImgeView.image = UIImage(named: "Checkbox_normal")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! BankTableViewCell
        
        if chekBank(bank: cell.bank, selected: selectedBanks) {
            cell.chekboxImgeView.image = UIImage(named: "Checkbox_normal")
            
            guard let index = selectedBanks.firstIndex(
                    where: {$0.bic == cell.bank.bic}) as Int? else { return }
            selectedBanks.remove(at: index)
        } else {
            cell.chekboxImgeView.image = UIImage(named: "Checkbox_active")
            selectedBanks.append(banks[indexPath.item])
        }
    }
    
}
//MARK: - UITextFieldDelegate
extension MeToMeSearchBanksViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text != "" {
            banks = allBanks
            banks = banks.filter(
                {$0.rusName?.lowercased().contains(text.lowercased()) ?? false ||
                    $0.fullName?.lowercased().contains(text.lowercased()) ?? false})
        } else if text == ""{
            banks = allBanks
        }
        tableView.reloadData()
    }
}

