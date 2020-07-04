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
import AVFoundation

class GameViewController: UIViewController {
    
    static var homeScene: HomeScene?
    static var menuScene: MenuScene?
    static var gameScene: GameScene?
    
    static var audioPlayer: AVAudioPlayer?

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
        
        do
        {
            GameViewController.audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "chill-background-music", ofType: "mp3")!))
            GameViewController.audioPlayer?.prepareToPlay()
        }
        catch {
            print(error)
        }
        
        if let view = self.view as! SKView? {
            
                let homeScene = HomeScene(fileNamed: "HomeScene")
                homeScene?.scaleMode = .aspectFill
                view.presentScene(homeScene)
 
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)

                view.ignoresSiblingOrder = true
                //view.showsFPS = true
                //view.showsNodeCount = true
                //view.showsPhysics = true
        }
    }
    
    func playBackgroundMusic() -> Void {
        
        GameViewController.audioPlayer?.numberOfLoops = -1
        GameViewController.audioPlayer?.play()
    }
    
    func pause() -> Void {
        
        if((GameViewController.audioPlayer?.isPlaying) != nil)
        {
            GameViewController.audioPlayer?.stop()
        }
        else
        {

        }
    }
    
    func restart() -> Void {
        
        if((GameViewController.audioPlayer?.isPlaying) != nil)
        {
            GameViewController.audioPlayer?.currentTime = 0
            GameViewController.audioPlayer?.numberOfLoops = -1
            GameViewController.audioPlayer?.play()
        }
        else
        {
            GameViewController.audioPlayer?.numberOfLoops = -1
            GameViewController.audioPlayer?.play()
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {

           guard let key = presses.first?.key else { return }

           switch key.keyCode {

           case .keyboardP:
           
            if isDebug
            {
                GameViewController.gameScene?.drawPeel()
            }
               
            
           case .keyboardS:
            
            if isDebug
            {
                GameViewController.gameScene?.addSoap()
            }

           case .keyboardUpArrow:
               
               if isDebug
               {
                    GameViewController.gameScene?.jumpUp()
               }
            case .keyboardDownArrow:
                
                if isDebug
                {
                     GameViewController.gameScene?.slideDown()
                }
            case .keyboardB:

                if isDebug
                {
                     GameViewController.gameScene?.drawBat1()
                }
            case .keyboard2:

                if isDebug
                {
                     GameViewController.gameScene?.drawBat2()
                }
            case .keyboard3:

                if isDebug
                {
                     GameViewController.gameScene?.drawBat3()
                }
            case .keyboardE:

                if isDebug
                {
                     GameViewController.gameScene?.drawPortal()
                }
            case .keyboardZ:

                if isDebug
                {
                     GameViewController.gameScene?.drawBlondeZombie()
                }
            case .keyboardR:
                
                if isDebug
                {
                     GameViewController.gameScene?.drawRedZombie()
                }
            
           case .keyboardM:
            
                if isDebug
                {
                    GameViewController.gameScene?.drawMask()
            }
                
            default:
                
               if isDebug
               {
               
               }

            super.pressesBegan(presses, with: event)
            
        }

    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
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

        GameViewController.gameScene?.isPaused = true
        GameViewController.gameScene?.timer.invalidate()
        pause()
    }
    
    @objc func appMovedToForeground() {
        
        GameViewController.gameScene?.isPaused = false
        GameViewController.gameScene?.timer.invalidate()
        GameViewController.gameScene?.startLevel(level: String(levelData.currentLevel))
        playBackgroundMusic()
    }
}
