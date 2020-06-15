//
//  GameViewController.swift
//  coronarun
//
//  Created by Brian Limaye on 5/13/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    static var homeScene: HomeScene?
    static var menuScene: MenuScene?
    static var gameScene: GameScene?

    let isDebug: Bool = {
           
           var isDebug = false
           // function with a side effect and Bool return value that we can pass into assert()
           func set(debug: Bool) -> Bool {
               isDebug = debug
               return isDebug
           }
           // assert:
           // "Condition is only evaluated in playgrounds and -Onone builds."
           // so isDebug is never changed to true in Release builds
           assert(set(debug: true))
           return isDebug
       }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
                
                let homeScene = HomeScene(fileNamed: "HomeScene")
                homeScene?.scaleMode = .aspectFill
                view.presentScene(homeScene)
 
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)

                
                view.ignoresSiblingOrder = true
                view.showsFPS = true
                view.showsNodeCount = true
                view.showsPhysics = true
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {

           guard let key = presses.first?.key else { return }

           switch key.keyCode {

           case .keyboardC:

               if isDebug
               {
                   print("c pressed")
                   //gameScene.closingScene()
               }
           case .keyboardP:
           
               if isDebug
               {
                    print("p was pressed")
                    GameViewController.gameScene?.drawPeel()
               }

           case .keyboardG:
                
               if isDebug
               {
                    print("g was pressed")
                    GameViewController.gameScene?.drawBlueGerm()
               }
           case .keyboardH:
               
               if isDebug
               {
                    print("h was pressed")
                    GameViewController.gameScene?.drawGreenGerm()
               }
           case .keyboardUpArrow:
               
               if isDebug
               {
                    print("up-arrow was pressed")
                    GameViewController.gameScene?.jumpUp()
               }
            case .keyboardDownArrow:
                
                if isDebug
                {
                     print("down-arrow was pressed")
                     GameViewController.gameScene?.slideDown()
                }
            case .keyboardB:

                if isDebug
                {
                     print("B was pressed")
                     GameViewController.gameScene?.drawBat1()
                }
            case .keyboardE:

            if isDebug
            {
                 print("E was pressed")
                 GameViewController.gameScene?.drawPortal()
            }
           default:
                
               if isDebug
               {
                    print("different key detected")
               }

            super.pressesBegan(presses, with: event)
            
        }

    }

    override var shouldAutorotate: Bool {
        return true
    }
    

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func appMovedToBackground() {

        print("App moved to background!")
        GameViewController.gameScene?.isPaused = true
    }
    
    @objc func appMovedToForeground() {
        
        print("App moved to foreground!")
        GameViewController.gameScene?.isPaused = false
    }
}
