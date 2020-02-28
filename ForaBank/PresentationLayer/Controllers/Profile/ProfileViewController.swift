/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero
import Alamofire
import MobileCoreServices

class ProfileViewController: UIViewController {

    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var buttonUpdateImage: UIButton!
    
    var segueId: String? = nil

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "SignedIn" {
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(1)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.forceNonFade,
                HeroModifier.opacity(1)
            ]
            menu.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(3)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: -view.frame.width, y: 0))
            ]
        }
        if segueId == "Registered" {
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(2)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.forceNonFade,
                HeroModifier.opacity(1),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            menu.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(3)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.translate(CGPoint(x: -view.frame.width, y: 0))
            ]
        }
        NetworkManager.shared().getProfile { [weak self] (success, profile, errorMessage) in
            if success, let firstName = profile?.firstName, let lastName = profile?.lastName
            {
                self?.nameLabel.text = "\(firstName)\n\(lastName)"
                if let imageData = UserDefaults.standard.data(forKey: "userImageView"){
                    if let imageUI = UIImage(data: imageData){
                        self!.userImageView.image = imageUI
                    }else{
                        let imageDefault = UIImage(named: "photoAdd")
                        self!.userImageView.image = imageDefault
                    }
                }else{
                    let imageDefault = UIImage(named: "photoAdd")
                    self!.userImageView.image = imageDefault
                }
            }else {
                print("ProfileViewController: \(errorMessage ?? "error without errorMessage")")
                self?.nameLabel.text = "Упс, что-то не загрузилось"
                //self?.userImageView.image = UIImage(named: "image_profile_samplephoto")
                if NetworkManager.shared().checkForClosingSession(errorMessage) == true {
                    let rootVC = self?.storyboard?.instantiateViewController(withIdentifier: "LoginOrSignupViewController") as! LoginOrSignupViewController
                    NetworkManager.shared().logOut { [weak self] (_) in
                        if let t = self?.navigationController?.tabBarController as? TabBarController {
                            t.setNumberOfTabsAvailable()
                        }
                    }
                    if let pvc = self?.parent as? ProfileViewController {
                        pvc.segueId = "logout"
                    }
                    rootVC.segueId = "logout"
                    self?.navigationController?.setViewControllers([rootVC], animated: true)
                }
            }
        }
    }
    
    private func getImageOfDefoultSave()-> UIImage{
        let imageUser = UIImageView()
        
        return imageUser.image!
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        menu.hero.modifiers = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "logout" {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: containerView.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
        view.hero.modifiers = nil
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsViewController" {
            segueId = nil
        }
    }
    
    @IBAction func actionUpdatePhoto(_ sender: Any) {
        getImage()
    }
}

//MARK: Update Image
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate{
    
    //создаем actionSheet с действиями
    private func getImage(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet) // создаем встлывающее окно
        let camera = UIAlertAction(title: "Сделать фото", style: .default) { (_) in
            self.chooseImagePicker(source: .camera)
        }
        let photo = UIAlertAction(title: "Выбрать фото", style: .default) { (_) in
            self.chooseImagePicker(source: .photoLibrary)
        }
        let documents = UIAlertAction(title: "Выбрать документ", style: .default) { [weak self](_) in
            self!.openiCloudDocuments()
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(documents)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
    }
    
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){ // если данный источник доступен
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true // для редактирования изображения
            imagePicker.sourceType = source // определяем откуда будет взято изображение
            present(imagePicker, animated: true)
        }
        
    }
    
    //получаем выбраное фото
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageData = (info[.editedImage] as? UIImage)?.pngData()
        updateImagePerson(imageData)
        userImageView.image = info[.editedImage] as? UIImage // присваиваем отредактирование изображение
        userImageView.contentMode = .scaleToFill // распределяем изображение по формату
        userImageView.clipsToBounds = true // обрезаем границы
        dismiss(animated: true)
    }
    
    //Open documents and import only image
    func openiCloudDocuments(){
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeImage)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let url = urls.first
        do {
            let documentData = try Data(contentsOf: url!, options: .dataReadingMapped)
            if let image = UIImage(data: documentData){
                updateImagePerson(documentData)
                userImageView.image = image
                userImageView.contentMode = .scaleToFill  // распределяем изображение по формату
                userImageView.clipsToBounds = true // обрезаем границы
            }else{
                print("Error image update")
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    //обновляем данные изобрадения
    private func updateImagePerson(_ imageData: Data?){
        guard let data = imageData else{return}
        UserDefaults.standard.removeObject(forKey: "userImageView")
        UserDefaults.standard.set(data, forKey: "userImageView")
    }
}
