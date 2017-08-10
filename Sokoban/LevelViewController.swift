//
//  LevelViewController.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 23.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit
import AudioToolbox

public enum playerMoveDirection {
    case undefined
    case bottomToTop
    case topToBottom
    case rightToLeft
    case leftToRight
}

let cellSize = 100

class LevelViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var levelScrollView: UIScrollView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    var showedTurnes: Array<(Int, Int)> = []
    var levelView = UIView()
    var turnsLayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Получаем уровень
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel
        
        // 2. Задаем размеры контейнера и content scroll view
        levelScrollView.contentSize = CGSize.init(width: level.width * cellSize, height: level.height * cellSize)
        levelScrollView.addSubview(levelView)
        levelView.frame = CGRect.init(x: 0, y: 0, width: level.width * cellSize, height: level.height * cellSize)

        turnsLayer.frame = levelView.frame
        levelView.layer.addSublayer(turnsLayer)
        
        // 3. Масштабируем scroll view для вписывания контейнера в экран
        levelScrollView.delegate = self
        setLevelScrollViewZoom()

        createLevel()

        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector (self.tapOnLevel(_:)))
        levelView.addGestureRecognizer(tapGesture)
        
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.color = UIColor.gray
        activityIndicatorView.isHidden = true
        activityIndicatorView.transform = CGAffineTransform(scaleX: 2, y: 2);
        levelView.addSubview(activityIndicatorView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.processingDone(_:)), name: NSNotification.Name(rawValue: "processingDone"), object: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return levelView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setLevelScrollViewZoom() {
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel

        let hMinZoom = UIScreen.main.bounds.width / (CGFloat)(level.width * cellSize)
        let vMinZoom = UIScreen.main.bounds.height / (CGFloat)(level.height * cellSize)
        
        levelScrollView.minimumZoomScale = min(hMinZoom, vMinZoom)
        
        levelScrollView.maximumZoomScale = 1.0
        
        levelScrollView.zoomScale = levelScrollView.minimumZoomScale
    }

    func setLevelScrollViewContentInCenter() {
        let offsetX = max((UIScreen.main.bounds.width - levelScrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((UIScreen.main.bounds.height - levelScrollView.contentSize.height) * 0.5, 0)
        levelScrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setLevelScrollViewContentInCenter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setLevelScrollViewZoom()
        setLevelScrollViewContentInCenter()
    }

    func createLevel() {
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel

        // Рисуем статичную картинку на подложке (levelContainerView.layer)
        let levelSize = CGSize(width: cellSize * level.width, height: cellSize * level.height)
        UIGraphicsBeginImageContextWithOptions(levelSize, false, 0.0)

        var image: UIImage
        for (i, row) in level.table.enumerated() {
            for (j, cell) in row.enumerated() {
                if cell.type == .empty || cell.type == .wall {
                    image = UIImage(named: cell.imageName)!
                    image.draw(in: CGRect.init(x: j * cellSize, y: i * cellSize, width: cellSize, height: cellSize))
                } else if cell.type == .goal || cell.type == .boxOnAGoal || cell.type == .playerOnAGoal {
                    image = UIImage(named: "goal")!
                    image.draw(in: CGRect.init(x: j * cellSize, y: i * cellSize, width: cellSize, height: cellSize))
                }
            }
        }
        
        for (i, row) in level.table.enumerated() {
            for (j, _) in row.enumerated() {
                // Рисуем сплошную стену в случае, если окружают блоки типа .wall
                if i < level.table.count - 1 && j < level.table[i].count - 1 && level.table[i][j].type == .wall && level.table[i + 1][j].type == .wall && level.table[i][j + 1].type == .wall && level.table[i + 1][j + 1].type == .wall {
                    image = UIImage(named: "wall")!
                    image.draw(in: CGRect.init(x: j * cellSize + cellSize / 2, y: i * cellSize + cellSize / 2, width: cellSize, height: cellSize))
                }
            }
        }

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        levelView.layer.contents = newImage.cgImage
        UIGraphicsEndImageContext()
        
        for (i, row) in level.table.enumerated() {
            for (j, cell) in row.enumerated() {
                if cell.type == .empty /* || cell.type == .goal */ || cell.type == .player || cell.type == .box || cell.type == .boxOnAGoal || cell.type == .playerOnAGoal {
                    image = UIImage(named: cell.imageName)!
                    cell.dynamicElement = UIImageView(frame: CGRect(x: j * cellSize, y: i * cellSize, width: cellSize, height: cellSize))
                    cell.dynamicElement?.image = image
                    levelView.addSubview(cell.dynamicElement!)
                }
            }
        }
        
        levelView.layer.needsDisplay()
        
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.startProcessing), userInfo: nil, repeats: false)
    }
    
    func startProcessing() {
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel
        level.startProcessing()
    }
    
    var tapRow = -1
    var tapColumn = -1
    
    func tapOnLevel(_ sender: UITapGestureRecognizer) {
        // Возможные варианты тапа:
        // 1. Тап на стену - выключение вариантов возможных ходов и передвижения ящика
        // 2. Тап на пустое место - передвижение игрока на пустое место (если возможно)
        // 3. Тап на возможное место передвижения игрока - выключение вариантов возможных ходов и передвижение игрока
        // 4. Тап на игрока - включение или выключение возможных вариантов ходов
        // 5. Тап на ящик - включение или выключение показа возможных вариантов передвижения ящика
        // 6. Тап на возможный вариант передвижения ящика - выключение показа возможных вариантов и передвижение ящика

        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel

        let touchPoint = sender.location(in: levelView)
        let j = Int(Int(touchPoint.x) / cellSize)
        let i = Int(Int(touchPoint.y) / cellSize)

        tapRow = i
        tapColumn = j
        
        let cell = level.table[i][j]
        
        if cell.type == .wall && showedTurnes.count > 0 {         // 1. Тап на стену - выключение вариантов возможных ходов и передвижения ящика
            hideTurnes()
        } else if cell.type == .empty || cell.type == .goal {     // 2. Тап на пустое место - передвижение игрока на пустое место (если возможно)
            
        }
        
        if cell.type == .box || cell.type == .boxOnAGoal || cell.type == .player || cell.type == .playerOnAGoal {
            if cell.processingCells == nil {
                activityIndicatorView.frame = CGRect(x: j * cellSize + 3, y: i * cellSize + 3, width: 100, height: 100)
                levelView.bringSubview(toFront: activityIndicatorView)
                activityIndicatorView.isHidden = false
                activityIndicatorView.startAnimating()
                cell.dynamicElement?.alpha = 0.3
            } else if let processingCells = cell.processingCells {
                if processingCells.count > 0 {
                    showedTurnes.count > 0 ? hideTurnes() : showTurn()
                } else {
                    // Фигушки, ходов нет, показывать нечего! Вибрируем NOPE
                    AudioServicesPlaySystemSound(1521)
                }
            }
        }
    }
    
    func processingDone(_ notification: NSNotification) {
        if let coordinate = notification.userInfo?["coordinate"] as? (Int, Int) {
            let storage = SPStorage.shared
            let level = storage.currentLevelCollection.currentLevel
            
            let cell = level.table[coordinate.0][coordinate.1]

            DispatchQueue.main.async {
                cell.dynamicElement?.alpha = 1
                
                if coordinate.0 == self.tapRow && coordinate.1 == self.tapColumn {
                    self.activityIndicatorView.isHidden = true
                    self.showedTurnes.count > 0 ? self.hideTurnes() : self.showTurn()
                }
             }
        }
    }
    
    func showTurn() {
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel
        let cell = level.table[tapRow][tapColumn]
        
        showedTurnes = cell.processingCells!
        
        let levelSize = CGSize(width: cellSize * level.width, height: cellSize * level.height)
        UIGraphicsBeginImageContextWithOptions(levelSize, false, 0.0)
        
        guard let processingCells = cell.processingCells else { return }

        let image = UIImage(named: cell.type == .player || cell.type == .playerOnAGoal ? "possibleToMove" : "possibleToPush")!
        
        for turn in processingCells.enumerated() {
            image.draw(in: CGRect.init(x: turn.element.1 * cellSize, y: turn.element.0 * cellSize, width: cellSize, height: cellSize))
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        turnsLayer.contents = newImage.cgImage
        UIGraphicsEndImageContext()
    }
    
    func hideTurnes() {
        tapRow = -1
        tapColumn = -1
        showedTurnes.removeAll()
        
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel
        
        let levelSize = CGSize(width: cellSize * level.width, height: cellSize * level.height)
        UIGraphicsBeginImageContextWithOptions(levelSize, false, 0.0)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        turnsLayer.contents = newImage.cgImage
        UIGraphicsEndImageContext()
    }
}
