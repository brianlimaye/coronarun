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
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                               
                // Set the scale mode to scale to fit the window
            
                
                //scene.scaleMode = .aspectFill
                
                /*
                let leadingConstraint = view.leadingAnchor.constraint(equalTo: )
                let trailingConstraint = landscapeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                let topConstraint = landscapeView.topAnchor.constraint(equalTo: self.view.topAnchor)
                let bottomConstraint = landscapeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
                
                initialConstraints.append(contentsOf: [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
                
                //NSLayoutConstraint.activate(initialConstraints)
                */
                
                // Present the scene.
                
                
                
                let homeScene = HomeScene(fileNamed: "HomeScene")
                homeScene?.scaleMode = .aspectFill
                view.presentScene(homeScene)
 
                
               //view.presentScene(scene)
                
                
                
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)

            }

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

           case .keyboard9:
               
               if isDebug
               {
                    print("9 was pressed")
                    GameViewController.gameScene?.drawGirl()
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
                     GameViewController.gameScene?.drawBats()
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
            return .portrait
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
        
        /*
        let children = GameViewController.gameScene?.children
       
        if((GameViewController.gameScene?.gameIsOver()) != nil)
        {
            for child in children!
            {
                if(child.isEqual(to: backGBlur))
                {
                    for backG in backGBlur.children {
                        
                        backG.speed = 0
                    }
                }
                
                if((child.name == "platform0") || (child.name == "platform1"))
                {
                    child.speed = 0
                }
            }
        }
 */
        GameViewController.gameScene?.isPaused = false
    }
}
