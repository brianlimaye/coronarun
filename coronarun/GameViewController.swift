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
    
    var gameScene = GameScene()
    
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
                
                self.gameScene = scene as! GameScene
                // Set the scale mode to scale to fit the window
                
                scene.scaleMode = .aspectFill
                
                /*
                let leadingConstraint = view.leadingAnchor.constraint(equalTo: )
                let trailingConstraint = landscapeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                let topConstraint = landscapeView.topAnchor.constraint(equalTo: self.view.topAnchor)
                let bottomConstraint = landscapeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
                
                initialConstraints.append(contentsOf: [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
                
                //NSLayoutConstraint.activate(initialConstraints)
                */
                
                // Present the scene.
                
                view.presentScene(scene)
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
                   
                   self.gameScene.closingScene()
               }
           case .keyboardLeftArrow:

               print("left arrow pressured")

           default:

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
}
