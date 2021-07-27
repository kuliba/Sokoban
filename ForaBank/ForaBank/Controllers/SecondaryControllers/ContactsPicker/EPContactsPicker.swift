//
//  EPContactsPicker.swift
//  EPContacts
//
//  Created by Prabaharan Elangovan on 12/10/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit
import Contacts


public protocol EPPickerDelegate: AnyObject {
	func epContactPicker(_: EPContactsPicker, didContactFetchFailed error: NSError)
    func epContactPicker(_: EPContactsPicker, didCancel error: NSError)
    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact)
	func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact])
}

public extension EPPickerDelegate {
	func epContactPicker(_: EPContactsPicker, didContactFetchFailed error: NSError) { }
	func epContactPicker(_: EPContactsPicker, didCancel error: NSError) { }
	func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact) { }
	func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) { }
}

typealias ContactsHandler = (_ contacts : [CNContact] , _ error : NSError?) -> Void

public enum SubtitleCellValue{
    case phoneNumber
    case email
    case birthday
    case organization
}

open class EPContactsPicker: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let searchContact: SearchContact = UIView.fromNib()
    let tableView = UITableView(frame: .zero, style: .plain)
    // MARK: - Properties
    
    open weak var contactDelegate: EPPickerDelegate?
    var contactsStore: CNContactStore?
    var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    var sortedContactKeys = [String]()
    
    var selectedContacts = [EPContact]()
    var filteredContacts = [CNContact]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var subtitleCellValue = SubtitleCellValue.phoneNumber
    var multiSelectEnabled: Bool = false //Default is single selection contact
    var isSearch = false
    // MARK: - Lifecycle Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
//        self.title = EPGlobalConstants.Strings.contactsTitle
        configureTableView()
        registerContactCell()
        inititlizeBarButtons()
        
        
        self.view.addSubview(searchContact)
        self.view.addSubview(tableView)
        view.backgroundColor = .white
        searchContact.buttonStackView.isHidden = false
        searchContact.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 44)
        tableView.anchor(top: searchContact.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16)
        searchContact.delegateNumber = self
        
        reloadContacts()
    }
    
    func inititlizeBarButtons() {
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 16)
        label.text = EPGlobalConstants.Strings.contactsTitle
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onTouchCancelButton))
        
        self.navigationItem.rightBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
    }
    
    fileprivate func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
    }
    
    fileprivate func registerContactCell() {
        
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: EPGlobalConstants.Strings.bundleIdentifier, withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                
                let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: bundle)
                tableView.register(cellNib, forCellReuseIdentifier: "Cell")
            }
            else {
                assertionFailure("Could not load bundle")
            }
        }
        else {
            
            let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: "Cell")
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Initializers
  
    convenience public init(delegate: EPPickerDelegate?) {
        self.init(delegate: delegate, multiSelection: false)
    }
    
    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool) {
        self.init()
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
    }

    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool, subtitleCellType: SubtitleCellValue) {
        self.init()
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
        subtitleCellValue = subtitleCellType
    }
    
    
    // MARK: - Contact Operations
  
      open func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        })
      }
  
    func getContacts(_ completion:  @escaping ContactsHandler) {
        if contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            contactsStore = CNContactStore()
        }
        let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
            case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
                //User has denied the current app to access the contacts.
                
                let productName = Bundle.main.infoDictionary!["CFBundleName"]!
                
                let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: {  action in
                    completion([], error)
                    self.dismiss(animated: true, completion: {
                        self.contactDelegate?.epContactPicker(self, didContactFetchFailed: error)
                    })
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            
            case CNAuthorizationStatus.notDetermined:
                //This case means the user is prompted for the first time for allowing contacts
                contactsStore?.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
                    //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                    if  (!granted ){
                        DispatchQueue.main.async(execute: { () -> Void in
                            completion([], error! as NSError?)
                        })
                    }
                    else{
                        self.getContacts(completion)
                    }
                })
            
            case  CNAuthorizationStatus.authorized:
                //Authorization granted by user for this app.
                var contactsArray = [CNContact]()
                
                let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
                
                do {
                    try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                        //Ordering contacts based on alphabets in firstname
                        contactsArray.append(contact)
                        var key: String = "#"
                        //If ordering has to be happening via family name change it here.
                        if let firstLetter = contact.givenName[0..<1] , firstLetter.containsAlphabets() {
                            key = firstLetter.uppercased()
                        }
                        var contacts = [CNContact]()
                        
                        if let segregatedContact = self.orderedContacts[key] {
                            contacts = segregatedContact
                        }
                        contacts.append(contact)
                        self.orderedContacts[key] = contacts

                    })
                    self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                    if self.sortedContactKeys.first == "#" {
                        self.sortedContactKeys.removeFirst()
                        self.sortedContactKeys.append("#")
                    }
                    completion(contactsArray, nil)
                }
                //Catching exception as enumerateContactsWithFetchRequest can throw errors
                catch let error as NSError {
                    print(error.localizedDescription)
                }
        @unknown default:
            print("Error CNContactStore.authorizationStatus")
        }
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    
    // MARK: - Table View DataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if isSearch { return 1 }
        return sortedContactKeys.count
    }
    
     open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch { return
            filteredContacts.count }
        if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
            return contactsForSection.count
        }
        return 0
    }

    // MARK: - Table View Delegates

     open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EPContactCell
        cell.accessoryType = .none
        //Convert CNContact to EPContact
		let contact: EPContact
        if isSearch {
            contact = EPContact(contact: filteredContacts[(indexPath as NSIndexPath).row])
        } else {
			guard let contactsForSection = orderedContacts[sortedContactKeys[(indexPath as NSIndexPath).section]] else {
				assertionFailure()
				return UITableViewCell()
			}

			contact = EPContact(contact: contactsForSection[(indexPath as NSIndexPath).row])
        }
		
        if multiSelectEnabled  && selectedContacts.contains(where: { $0.contactId == contact.contactId }) {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
		
        cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: subtitleCellValue)
        return cell
    }
    
     open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! EPContactCell
        let selectedContact =  cell.contact!
        if multiSelectEnabled {
            //Keeps track of enable=ing and disabling contacts
            if cell.accessoryType == UITableViewCell.AccessoryType.checkmark {
                cell.accessoryType = UITableViewCell.AccessoryType.none
                selectedContacts = selectedContacts.filter(){
                    return selectedContact.contactId != $0.contactId
                }
            }
            else {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                selectedContacts.append(selectedContact)
            }
        }
        else {
            //Single selection code
            isSearch = false

			self.dismiss(animated: true, completion: {
				DispatchQueue.main.async {
					self.contactDelegate?.epContactPicker(self, didSelectContact: selectedContact)
				}
			})
        }
    }
    
     open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    open  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
     open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if isSearch { return 0 }
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableView.ScrollPosition.top , animated: false)
        return sortedContactKeys.firstIndex(of: title)!
    }
    
      open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearch { return nil }
        return sortedContactKeys
    }

//    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if resultSearchController.isActive { return nil }
//        return sortedContactKeys[section]
//    }
    
    // MARK: - Button Actions
    
    @objc func onTouchCancelButton() {
        dismiss(animated: true, completion: {
            self.contactDelegate?.epContactPicker(self, didCancel: NSError(domain: "EPContactPickerErrorDomain", code: 2, userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
        })
    }
    
    @objc func onTouchDoneButton() {
        dismiss(animated: true, completion: {
            self.contactDelegate?.epContactPicker(self, didSelectMultipleContacts: self.selectedContacts)
        })
    }
    
    // MARK: - Search Actions
    private func searchForContactUsingName(text: String) {
        
        var predicate: NSPredicate
        if text.count > 0 {
            isSearch = true
            predicate = CNContact.predicateForContacts(matchingName: text)
        } else {
            predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactsStore!.defaultContainerIdentifier())
        }
        
        let store = CNContactStore()
        do {
            filteredContacts = try store.unifiedContacts(matching: predicate,
                                                         keysToFetch: allowedContactKeys())
        }
        catch {
            print("Error!")
        }
    }
    
    func check(_ givenString: String) -> Bool {
        return givenString.range(of: "^[7-8]9.", options: .regularExpression) != nil
    }
    
    private func searchForContactUsingPhoneNumber(phoneNumber: String) {
        DispatchQueue.global().async {
            var searchNumber = phoneNumber
            if searchNumber.count > 0 {
                
                self.isSearch = true
                var contacts = [CNContact]()
                var message: String!
                
                let contactsStore = CNContactStore()
                do { try contactsStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: self.allowedContactKeys())) {
                    (contact, cursor) -> Void in
                    if (!contact.phoneNumbers.isEmpty) {
                        
                        let phoneNumberToCompareAgainst =  searchNumber.components(
                            separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                        for phoneNumber in contact.phoneNumbers {
                            if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                                let phoneNumberString = phoneNumberStruct.stringValue
                                var phoneNumberToCompare = phoneNumberString.components(
                                    separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                                if self.check(phoneNumberToCompare)  {
                                    phoneNumberToCompare = String(phoneNumberToCompare.dropFirst())
                                }
                                let phoneNumberFin = phoneNumberToCompare.prefix(phoneNumberToCompareAgainst.count)
                                if phoneNumberFin == phoneNumberToCompareAgainst {
                                    contacts.append(contact)
                                }
                            }
                        }
                    }
                }
                
                if contacts.count == 0 {
                    message = "No contacts were found matching the given phone number."
                    print(message!)
                }
                } catch {
                    message = "Unable to fetch contacts."
                }
                if message != nil {
                    DispatchQueue.main.async {
                        print(message!)
                    }
                } else {
                    // Success
                    DispatchQueue.main.async {
                        
                        self.filteredContacts = contacts
//                        let contact = contacts[0] // For just the first contact (if two contacts had the same phone number)
//                        print(contact.givenName) // Print the "first" name
//                        print(contact.familyName) // Print the "last" name
//                        if contact.isKeyAvailable(CNContactImageDataKey) {
//                            if let contactImageData = contact.imageData {
//                                print(UIImage(data: contactImageData)) // Print the image set on the contact
//                            }
//                        } else {
//                            // No Image available
//                        }
                    }
                }
            }
        }
    }
    
}

extension EPContactsPicker: passTextFieldText {
    func passTextFieldText(text: String) {
        let searchText = text
        if searchText.isNumeric {
            if self.check(searchText)  {
                searchContact.numberTextField.text = String(searchText.dropFirst())
            }
            searchForContactUsingPhoneNumber(phoneNumber: searchText)
        } else {
            searchForContactUsingName(text: searchText)
        }
        
    }
}
