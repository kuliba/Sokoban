//
//  OnBoardingViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import Alamofire

class OnBoardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    let urlString = "https://git.briginvest.ru/dbo/api/v2/rest/getOperatorsList"
    var operationArray = [OperationsList]()

    
    @IBAction func action(_ sender: Any) {
        func getOperations(headers: HTTPHeaders, completionHandler: @escaping (Bool, [OperationsList]?, String?) -> Void) {
            guard let url = Foundation.URL(string: urlString) else { return }
            let urlRequest = URLRequest(url: url)
            Alamofire.request(urlRequest)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
                .responseJSON { response in
                let json = response.data
                
                do{
                    let decoder = JSONDecoder()
                    self.operationArray = try decoder.decode([OperationsList].self, from: json!)
                    for operations in self.operationArray{
                        print(operations.data!)
                    }
                } catch {
                    print(error)
                }
            }
        }
        
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: ButtonRounded!
    @IBOutlet weak var skipButton: UIButton!
    
    var delegate: OperationListService?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // Do any additional setup after loading the view.
       
    
        }
        
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            //show onboarding
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onBoardCell", for: indexPath) as! OnBoardingCollectionViewCell

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (nextButton.frame.height + skipButton.frame.height))
    }

}



class Core  {
    
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() -> Bool {
        UserDefaults.standard.bool(forKey: "isNewUser")
    }
}
