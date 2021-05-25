//
//  EventViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import Alamofire



class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //defining the API URL
    let API_URL = "https://kudago.com/public-api/v1.4/movies/"
    var moviesList = EventModel()
    var eventDay = ["1","2"]

    override func viewDidLoad() {
          super.viewDidLoad()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 5);
        searchBar.showsScopeBar = false
        searchBar.searchBarStyle = .minimal
        self.searchBar.backgroundImage = UIImage()
        searchBar.layer.borderWidth = 0

        func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
          Alamofire.request(API_URL).responseJSON { response in
              let json = response.data
              
              do{
                  //created the json decoder
                  let decoder = JSONDecoder()
                  
                  //using the array to put values
                  self.moviesList = try decoder.decode(EventModel.self, from: json!)
                  
                  //printing all the hero names
                for hero in 0..<(self.moviesList.results!.count-1){
                    print(self.moviesList.results)
                    self.collectionView.reloadData()
                  }
                  
              }catch let err{
                  print(err)
              }
          }
      }
    

    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        return  self.moviesList.results?.count ?? 0
       }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) 

            reusableview.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 100)
             //do other header related calls or settups
                return reusableview


        default:  fatalError("Unexpected element kind")
        }
    }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OperationsCell", for: indexPath) as! OperationsListCollectionViewCell
//        cell.label.text = moviesList.results![indexPath.row].title ?? "label"
//        let imageUrl:NSURL = NSURL(string: (moviesList.results?[indexPath.row].poster?.image)!)!
//        DispatchQueue.global(qos: .userInitiated).async {
//
//                  let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
//
//                  DispatchQueue.main.async {
//
//                      let image = UIImage(data: imageData as Data)
//                    cell.image.image = image
//                    }
//
//        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    

        guard collectionView.cellForItem(at: indexPath as IndexPath) != nil else { return }

        performSegue(withIdentifier: "selectEvent", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
         if segue.identifier == "selectEvent"{
            guard let indexPath = (sender as? UIView)?.findCollectionViewIndexPath() else { return }
             let searchBankVC = segue.destination as!  EventDetailsViewController
            searchBankVC.idFilm = "\(moviesList.results![indexPath.row].id!)"
            
         } else {
            let searchBankVC = segue.destination as!  EventDetailsViewController
            searchBankVC.idFilm = "3141"

        }
         }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/3.5, height: collectionView.bounds.height)
    }

    }

    

extension UIView {

    func findCollectionView() -> UICollectionView? {
        if let collectionView = self as? UICollectionView {
            return collectionView
        } else {
            return superview?.findCollectionView()
        }
    }

    func findCollectionViewCell() -> UICollectionViewCell? {
        if let cell = self as? UICollectionViewCell {
            return cell
        } else {
            return superview?.findCollectionViewCell()
        }
    }

    func findCollectionViewIndexPath() -> IndexPath? {
        guard let cell = findCollectionViewCell(), let collectionView = cell.findCollectionView() else { return nil }

        return collectionView.indexPath(for: cell)
    }

}
