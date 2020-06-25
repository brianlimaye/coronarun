//
//  GameScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/13/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate
{
    struct ColliderType
    {
        static let none: UInt32 = 0x1 << 0
        static let character: UInt32 = 0x1 << 1
        static let banana: UInt32 = 0x1 << 2
        static let bluegerms: UInt32 = 0x1 << 3
        static let greengerms: UInt32 = 0x1 << 4
        static let soap: UInt32 = 0x1 << 5
        static let portal: UInt32 = 0x1 << 6
        static let bat: UInt32 = 0x1 << 7
        static let mask: UInt32 = 0x1 << 8
    }

    struct game {
       
       static var IsOver : Bool = false
       static var contactDetected: Bool = false
       static var i: Int = 0
       static var charInitialPos: CGPoint = CGPoint(x: 0, y: 0)
       static var zombieInitialSize: CGSize = CGSize(width: 0, height: 0)
       
       static var levelOneObjects: [Int] = [2, 8, 4, 2, 5, 8, 2, 1, 2, 1, 6, 8, 3, 7]
       static var levelTwoObjects: [Int] = [4, 3, 2, 8, 3, 3, 8, 5, 1, 2, 6, 1, 8, 7]
       static var levelThreeObjects: [Int] = [4, 2, 8, 1, 3, 2, 5, 8, 6, 1, 8, 3, 2, 7]
       static var levelFourObjects: [Int] = [1, 1, 4, 5, 2, 8, 3, 1, 6, 8, 3, 8, 3, 7]
       static var levelFiveObjects: [Int] = [2, 8, 2, 4, 3, 1, 5, 3, 8, 3, 1, 8, 6, 7]
   }
    
    let playerSpeedPerFrame = 0.25
    let playerJumpPerFrame = 1.0
    let maxTimeMoving: CGFloat = 2
    let bgAnimatedInSecs: TimeInterval = 3
    let MIN_THRESHOLD_MS: Double = 1000
    
    static let defaults = UserDefaults.standard
    
    var isMasked: Bool = false
    var audioPlayer: AVAudioPlayer?
    var portal: SKSpriteNode = SKSpriteNode()
    var blueGerms: SKEmitterNode = SKEmitterNode()
    var greenGerms: SKEmitterNode = SKEmitterNode()
    var glitter: SKEmitterNode = SKEmitterNode()
    var soap: SKSpriteNode = SKSpriteNode()
    var characterSprite: SKSpriteNode = SKSpriteNode()
    var redZombie: SKSpriteNode = SKSpriteNode()
    var blondeZombie: SKSpriteNode = SKSpriteNode()
    var miniCharacter: SKSpriteNode = SKSpriteNode()
    var batSprite: SKSpriteNode = SKSpriteNode()
    var batSprite2: SKSpriteNode = SKSpriteNode()
    var batSprite3: SKSpriteNode = SKSpriteNode()
    var blueGermCloud: SKSpriteNode = SKSpriteNode()
    var greenGermCloud: SKSpriteNode = SKSpriteNode()
    var bananaPeel: SKSpriteNode = SKSpriteNode()
    var replayButton: SKSpriteNode = SKSpriteNode()
    var replayShape: SKShapeNode = SKShapeNode()
    var nextLevelButton: SKSpriteNode = SKSpriteNode()
    var nextLevelShape: SKShapeNode = SKShapeNode()
    var homeButton: SKSpriteNode = SKSpriteNode()
    var homeButtonShape: SKShapeNode = SKShapeNode()
    var menuButton: SKSpriteNode = SKSpriteNode()
    var menuButtonShape: SKShapeNode = SKShapeNode()
    var exclamationMark: SKSpriteNode = SKSpriteNode()
    var exclamationShape: SKShapeNode = SKShapeNode()
    var handSanitizerScore: Int = 0
    var temp: Int = 0
    var objNum: Int = 0
    var isLevelPassed: Bool = false
    var gameIsPaused: Bool = false
    var timer: Timer = Timer()
    var lastTime: Double = 0
    var gameOverDisplay: SKShapeNode = SKShapeNode()
    var levelAlert: SKLabelNode = SKLabelNode()
    var levelDisplay: SKLabelNode = SKLabelNode()
    var livesDisplay: SKLabelNode = SKLabelNode()
    var levelDisplayShape: SKShapeNode = SKShapeNode()
    var levelStatusAlert: SKLabelNode = SKLabelNode()
    var mask: SKSpriteNode = SKSpriteNode()
    var miniHandSanitizer: SKSpriteNode = SKSpriteNode()
    var scoreLabelShape: SKShapeNode = SKShapeNode()
    var scoreLabel: SKLabelNode = SKLabelNode()
    /*
    var pauseIcon: SKSpriteNode = SKSpriteNode()
    var pauseIconShape: SKShapeNode = SKShapeNode()
    var pauseDisplay: SKShapeNode = SKShapeNode()
    var pauseLevelDisplay: SKLabelNode = SKLabelNode()
    var pauseStatus: SKLabelNode = SKLabelNode()
    var tapToContinue: SKLabelNode = SKLabelNode()
 */
    
    override func didMove(to view: SKView) -> Void {

        GameViewController.gameScene = self
        self.physicsWorld.contactDelegate = self
        initializeGame()
    }
    
    func initializeGame() -> Void {
        
        //GameScene.defaults.removeObject(forKey: "maxlevel")
        //GameScene.defaults.removeObject(forKey: "handsanitizer")
        initScore()
        drawCharacter()
        resumeNodes()
        initObjects()
        showCurrentLevel()
        objNum = 0
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(jumpUp))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(slideDown))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
    }
    
    func playSneezeSound() {
        let url = Bundle.main.url(forResource: "sneeze-sound", withExtension: "mp3")!

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }

            player.prepareToPlay()
            player.play()

        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func resetLevelStatus() {
        
        levelData.pressedNext = false
        levelData.pressedReplay = false
    }
    
    func startLevel(level: String) {
        
        switch(level)
        {
            case "1":
                timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadLevel1), userInfo: nil, repeats: true)
            case "2":
                timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadLevel2), userInfo: nil, repeats: true)
            case "3":
                timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadLevel3), userInfo: nil, repeats: true)
            case "4":
                timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadLevel4), userInfo: nil, repeats: true)
            case "5":
                timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadLevel5), userInfo: nil, repeats: true)
            default:
                print("other..")
        }
    }
    
    func drawMask() {
        
        mask.isHidden = false
        let rotation = SKAction.rotate(byAngle: (-2 * CGFloat.pi), duration: bgAnimatedInSecs / 1.5)
        let xShift = SKAction.moveTo(x: -self.frame.width, duration: bgAnimatedInSecs / 1.5)
        let xReversion = SKAction.moveTo(x: self.frame.width, duration: 0)
        
        let xSeq = SKAction.sequence([xShift, xReversion])
        
        let rotationRepeater = SKAction.repeat(rotation, count: 1)
        let xShiftRepeater = SKAction.repeat(xSeq, count: 1)
        
        mask.run(rotationRepeater)
        mask.run(xShiftRepeater)
    }
    
    func initScore() {
                
        scoreLabel = SKLabelNode(fontNamed: "MotionControl-BoldItalic")
        scoreLabel.text = String(levelData.handSanitizerCount)
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 84
        
        miniHandSanitizer = SKSpriteNode(imageNamed: "hand-sanitizer.png")
        miniHandSanitizer.size = CGSize(width: miniHandSanitizer.size.width / 8, height: miniHandSanitizer.size.height / 8)
        miniHandSanitizer.position = CGPoint(x: -150, y: -50)
        scoreLabel.position = CGPoint(x: -100, y: -75)
        
        scoreLabelShape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: -200, height: -100), cornerRadius: 200)
        scoreLabelShape.alpha = 0.0
        
        scoreLabelShape.addChild(scoreLabel)
        scoreLabelShape.addChild(miniHandSanitizer)
    
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            scoreLabelShape.position.x = self.frame.width / 2
            scoreLabelShape.position.y = self.frame.height / 2.75
        }
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            scoreLabelShape.position.x = self.frame.width / 2
            scoreLabelShape.position.y = self.frame.height / 2.25
        }
 
        scoreLabelShape.fillColor = .clear
        scoreLabelShape.strokeColor = .white
        scoreLabelShape.lineWidth = 5
        scoreLabelShape.isAntialiased = true
        
        self.addChild(scoreLabelShape)
    }
    
    func updateAndShowScore() {
        
        levelData.handSanitizerCount += 1
        scoreLabel.text = String(levelData.handSanitizerCount)
        
        let fadeIn = SKAction.fadeIn(withDuration: bgAnimatedInSecs / 6)
        
        let fadeRepeater = SKAction.repeat(fadeIn, count: 1)
        
        scoreLabelShape.run(fadeRepeater, completion: fadeOut)
    }
    
    func fadeOut() {
        
        let fadeOut = SKAction.fadeOut(withDuration: bgAnimatedInSecs / 6)
        
        let fadeRepeater = SKAction.repeat(fadeOut, count: 1)
        
        scoreLabelShape.run(fadeRepeater, completion: fadeReversion)
    }
    
    func fadeReversion() {
        
        scoreLabelShape.alpha = 0.0
    }
    
    func showCurrentLevel() {
        
        levelDisplay.fontColor = .white
        levelDisplay.fontSize = 60
        levelDisplay.position = CGPoint(x: 0, y: self.frame.height / 14)
        levelDisplay.zPosition = 5
        
        if(!levelData.didLoadFromHome)
        {
            levelData.currentLevel = levelData.levelSelected
            levelDisplay.text = "World 1: Level " + String(levelData.levelSelected)
            levelData.didLoadFromHome = true
        }
        else
        {
            
            if(levelData.pressedReplay)
            {
                levelDisplay.text = "World 1: Level " + String(levelData.currentLevel)
            }
            else
            {
                if(!levelData.hasMastered)
                {
                    levelData.currentLevel = levelData.reachedLevel
                    levelDisplay.text = "World 1: Level " + String(levelData.reachedLevel)
                }
                else
                {
                    levelDisplay.text = "World 1: Level " + String(levelData.currentLevel)
                }
            }
        }
        
        resetLevelStatus()
        livesDisplay.fontColor = .white
        livesDisplay.fontSize = 48
        livesDisplay.text = " x 1"
        livesDisplay.position = CGPoint(x: 30, y: 30)
        livesDisplay.zPosition = 5
        
        
        miniCharacter.position = CGPoint(x: -30, y: 50)
        miniCharacter.size = CGSize(width: miniCharacter.size.width / 4, height: miniCharacter.size.height / 4)
        miniCharacter.zPosition = 5
        
        
        
        levelDisplayShape.fillColor = .black
        levelDisplayShape.alpha = 0.5
        levelDisplayShape.zPosition = 4
        
        let showLevel = SKAction.resize(toWidth: (2 * self.frame.width), duration: 3)
        
        let showLevelRepeater = SKAction.repeat(showLevel, count: 1)
    
        levelDisplayShape.run(showLevelRepeater, completion: fadeLevelDisplay)
    }
    
    func fadeLevelDisplay() {
        
        let fadeLevel = SKAction.fadeOut(withDuration: 0.5)
        
        let fadeRepeater = SKAction.repeat(fadeLevel, count: 1)
        
        levelDisplayShape.run(fadeRepeater, completion: fadeIn)
        livesDisplay.run(fadeRepeater)
        miniCharacter.run(fadeRepeater)
        levelDisplay.run(fadeRepeater)
    }
    
    func fadeIn() {

        levelDisplayShape.isHidden = true
        livesDisplay.isHidden = true
        miniCharacter.isHidden = true
        levelDisplay.isHidden = true
        
        levelDisplayShape.alpha = 0.5
        livesDisplay.alpha = 1
        miniCharacter.alpha = 1
        levelDisplay.alpha = 1
    
        /*
        if(levelData.didLoadFromHome)
        {
            startLevel(level: String(levelData.currentLevel))
        }
        else
        {
            startLevel(level: String(levelData.levelSelected))
        }
 */
    }
    
    func resumeNodes() {
        
        for child in cameraNode.children {
            
            if((child.name == "background0") || (child.name == "background1"))
            {
                child.speed = 1.75
            }
                
            if((child.name == "platform0") || (child.name == "platform1"))
            {
                child.speed = 1.75
            }
            
            else if(child.name == "character")
            {
                if((game.charInitialPos.x == 0) && (game.charInitialPos.y == 0))
                {
                    game.charInitialPos = child.position
                }
                child.isHidden = true
            }
        }
        
        if(!self.children.contains(cameraNode))
        {
            self.addChild(cameraNode)
        }
    }

    func runCorrespondingAction(num: Int) {
        
        switch(num)
        {
            case 1:
                drawPeel()
            case 2:
                drawBlondeZombie()
            case 3:
                drawRedZombie()
            case 4:
                drawBat1()
            case 5:
                drawBat2()
            case 6:
                drawBat3()
            case 7:
                drawPortal()
            case 8:
                addSoap()
            default:
                print("error....")
        }
    }
    
    @objc func loadLevel1() -> Void {
        
        if(objNum == 14)
        {
            timer.invalidate()
            objNum = 0
        }
        else
        {
            let rand = Int.random(in: 1...8)
                   
            if((rand == 1) && (!isMasked))
            {
                drawMask()
            }
            else
            {
                let currentObj = game.levelOneObjects[objNum]
                
                runCorrespondingAction(num: currentObj)
                
                objNum += 1
            }
        }
    }
    
    @objc func loadLevel2() {
        
        if(objNum == 14)
        {
            timer.invalidate()
            objNum = 0
        }
        else
        {
            let rand = Int.random(in: 1...8)
                   
            if((rand == 2) && (!isMasked))
            {
                drawMask()
            }
            
            else
            {
                let currentObj = game.levelTwoObjects[objNum]
                
                runCorrespondingAction(num: currentObj)
                
                objNum += 1
            }
        }
    }
    
    @objc func loadLevel3() {
        
        if(objNum == 14)
        {
            timer.invalidate()
            objNum = 0
        }
        else
        {
            let rand = Int.random(in: 1...8)
                   
            if((rand == 3) && (!isMasked))
            {
                drawMask()
            }
            else
            {
                let currentObj = game.levelThreeObjects[objNum]

                runCorrespondingAction(num: currentObj)
                
                objNum += 1
            }
        }
    }
    
    @objc func loadLevel4() {
        
        if(objNum == 14)
        {
            timer.invalidate()
            objNum = 0
        }
        else
        {
            let rand = Int.random(in: 1...8)
                   
            if((rand == 4) && (!isMasked))
            {
                drawMask()
            }
            else
            {
                let currentObj = game.levelFourObjects[objNum]
                
                runCorrespondingAction(num: currentObj)
                
                objNum += 1
            }
        }
    }
    
    @objc func loadLevel5() {
        
        if(objNum == 14)
        {
            timer.invalidate()
            objNum = 0
        }
        else
        {
            let rand = Int.random(in: 1...8)
                   
            if((rand == 5) && (!isMasked))
            {
                drawMask()
            }
            else
            {
                let currentObj = game.levelFiveObjects[objNum]
                
                runCorrespondingAction(num: currentObj)
                
                objNum += 1
            }
        }
    }
    
    func minimizeChar() {
        
        let minimizeEffect = SKAction.resize(toWidth: 0, height: 0, duration: bgAnimatedInSecs / 10)
        let bat1ToPortal = SKAction.move(to: portal.position, duration: bgAnimatedInSecs / 5)
        let bat2ToPortal = SKAction.move(to: portal.position, duration: bgAnimatedInSecs / 3)
        let bat3ToPortal = SKAction.move(to: portal.position, duration: bgAnimatedInSecs / 2)
        
        let bat1ToOffscreen = SKAction.move(to: CGPoint(x: self.frame.width, y: portal.frame.midY), duration: bgAnimatedInSecs / 9)
        let bat2ToOffscreen = SKAction.move(to: CGPoint(x: self.frame.width, y: self.frame.maxY / 2), duration: bgAnimatedInSecs / 9)
        let bat3ToOffscreen = SKAction.move(to: CGPoint(x: self.frame.width, y: self.frame.maxY), duration: bgAnimatedInSecs / 9)
        
        let bat1Seq = SKAction.sequence([bat1ToPortal, bat1ToOffscreen])
        let bat2Seq = SKAction.sequence([bat2ToPortal, bat2ToOffscreen])
        let bat3Seq = SKAction.sequence([bat3ToPortal, bat3ToOffscreen])
        
        let minimizeRepeater = SKAction.repeat(minimizeEffect, count: 1)
        let bat1Movement = SKAction.repeat(bat1Seq, count: 1)
        let bat2Movement = SKAction.repeat(bat2Seq, count: 1)
        let bat3Movement = SKAction.repeat(bat3Seq, count: 1)
        
        batSprite.run(bat1Movement)
        batSprite2.run(bat2Movement)
        batSprite3.run(bat3Movement)
        characterSprite.run(minimizeRepeater, completion: gameSuccession)
    }
    
    func gameSuccession() {
        
        if(levelData.currentLevel <= levelData.maxLevel - 1)
        {
            levelData.hasLocks[levelData.currentLevel] = false
        }
        
        characterSprite.isHidden = true
        
        let portalMinimize = SKAction.resize(toWidth: 0, height: 0, duration: bgAnimatedInSecs / 10)
        
        let portalMinimizeRepeater = SKAction.repeat(portalMinimize, count: 1)
    
        portal.run(portalMinimizeRepeater)
        isLevelPassed = true
        
        if(levelData.currentLevel == levelData.reachedLevel)
        {
            levelData.reachedLevel += 1
            //GameScene.defaults.set(levelData.handSanitizerCount, forKey: "handsanitizer")
            //GameScene.defaults.set(levelData.reachedLevel, forKey: "maxlevel")
        }
        
        endGame()
    }
    
    func makeCharDynamic() {
        
        characterSprite.physicsBody?.isDynamic = true
    }
    
    func addMaskToCharacter() {
        
        isMasked = true
        characterSprite.physicsBody?.isDynamic = true
        
        let maskedAnimations:[SKTexture] = [SKTexture(imageNamed: "masked-bobby-6.png"), SKTexture(imageNamed: "masked-bobby-7.png"), SKTexture(imageNamed: "masked-bobby-8.png"), SKTexture(imageNamed: "masked-bobby-9.png"), SKTexture(imageNamed: "masked-bobby-10.png"), SKTexture(imageNamed: "masked-bobby-11.png")]
    
        let mainAnimated = SKAction.animate(with: maskedAnimations, timePerFrame: 0.2)
        let mainRepeater = SKAction.repeatForever(mainAnimated)
        
        let filler = SKAction.resize(toWidth: characterSprite.size.width, height: characterSprite.size.height, duration: 0)
        
        let fillerRepeater = SKAction.repeat(filler, count: 1)


        characterSprite.run(fillerRepeater)
        characterSprite.run(mainRepeater, withKey: "maskedrunning")
        
    }
    
    func removeMask() {
        
        isMasked = false
        
        let runAnimations:[SKTexture] = [SKTexture(imageNamed: "bobby-6"), SKTexture(imageNamed: "bobby-7.png"), SKTexture(imageNamed: "bobby-8.png"), SKTexture(imageNamed: "bobby-9.png"), SKTexture(imageNamed: "bobby-10.png"), SKTexture(imageNamed: "bobby-11.png")]
        
        let filler = SKAction.resize(toWidth: characterSprite.size.width, height: characterSprite.size.height, duration: 0)
        
        
        let mainRunning = SKAction.animate(with: runAnimations, timePerFrame: 0.2)
        let mainRepeater = SKAction.repeatForever(mainRunning)
        
        let fillerRepeater = SKAction.repeat(filler, count: 1)
        
        characterSprite.run(mainRepeater, withKey: "running")
        characterSprite.run(fillerRepeater, completion: addGracePeriod)
   
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
                
        game.contactDetected = true
                
        let nodeA = contact.bodyA
        let nodeB = contact.bodyB
                
        if(((nodeA.node?.name == "character") && (nodeB.node?.name == "bat")) || ((nodeA.node?.name == "bat") && (nodeB.node?.name == "character")))
        {
            if(isMasked)
            {
                removeMask()
                game.contactDetected = false
            }
            else
            {
                characterSprite.physicsBody?.isDynamic = false
                batDieAnimation()
            }
        }
            
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "mask")) || ((nodeA.node?.name == "mask") && (nodeB.node?.name == "character")))
        {
            characterSprite.physicsBody?.isDynamic = false
            game.contactDetected = false
            mask.isHidden = true
            
            let fillerAction = SKAction.resize(toWidth: soap.size.width, duration: 0.5)
            
            let fillerRepeater = SKAction.repeat(fillerAction, count: 1)
            
            soap.run(fillerRepeater, completion: addMaskToCharacter)
            
        }
        
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "portal")) || ((nodeA.node?.name == "portal") && (nodeB.node?.name == "character")))
        {
            characterSprite.physicsBody?.isDynamic = false
            portal.physicsBody?.isDynamic = false
            minimizeChar()
        }
        
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "soap")) || ((nodeA.node?.name == "soap") && (nodeB.node?.name == "character")))
        {
            updateAndShowScore()
            characterSprite.physicsBody?.isDynamic = false
            soap.isHidden = true
            game.contactDetected = false
            
            let fillerAction = SKAction.resize(toWidth: soap.size.width, duration: 0.5)
            
            let fillerRepeater = SKAction.repeat(fillerAction, count: 1)
            
            soap.run(fillerRepeater, completion: makeCharDynamic)
        }
        
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "banana")) || ((nodeA.node?.name == "banana") && (nodeB.node?.name == "character")))
        {
            if(isMasked)
            {
                removeMask()
                game.contactDetected = false
            }
            else
            {
                self.view?.gestureRecognizers?.removeAll()
                peelDieAnimation()
            }
        }
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "bluegerms")) || ((nodeA.node?.name == "bluegerms") && (nodeB.node?.name == "character")))
        {
            if(isMasked)
            {
                removeMask()
                game.contactDetected = false
            }
            else
            {
                characterSprite.physicsBody?.isDynamic = false
                blueGerms.physicsBody?.isDynamic = false
                self.view?.gestureRecognizers?.removeAll()
                germDieAnimation(germ: blueGerms)
            }
        }
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "greengerms")) || ((nodeA.node?.name == "greengerms") && (nodeB.node?.name == "character")))
        {
            if(isMasked)
            {
                removeMask()
                game.contactDetected = false
            }
            else
            {
                characterSprite.physicsBody?.isDynamic = false
                greenGerms.physicsBody?.isDynamic = false
                self.view?.gestureRecognizers?.removeAll()
                germDieAnimation(germ: greenGerms)
            }
        }
    }
    
    func addGracePeriod() {
        
        characterSprite.physicsBody?.isDynamic = false
        let gracePeriodDuration = SKAction.resize(toWidth: characterSprite.size.width, height: characterSprite.size.height, duration: 1)
        let gracePeriodRepeater = SKAction.repeat(gracePeriodDuration, count: 1)
        
        characterSprite.run(gracePeriodRepeater, completion: makeCharDynamic)
    }

    func gameIsOver() -> Bool {
        
        return game.IsOver
    }
    
    func isReady() -> Bool{
        
        var isReady: Bool = true
        let currentTime = currentTimeInMilliSeconds()
    
        if((lastTime > 0) && (currentTime - lastTime) <= 1001)
        {
            isReady = false
        }
        lastTime = currentTime
        return isReady
    }
    
    func currentTimeInMilliSeconds()-> Double
    {
        let currentDate = Date()

        let since1970 = currentDate.timeIntervalSince1970

        return (since1970 * 1000)
    }
    
    /*
    func initPauseButton() -> Void {
        
        pauseIcon = SKSpriteNode(imageNamed: "pause-icon")
        pauseIcon.name = "pausebutton"
        pauseIcon.size = CGSize(width: pauseIcon.size.width * 1.5, height: pauseIcon.size.height * 1.5)
        pauseIcon.isUserInteractionEnabled = false
        pauseIcon.position = CGPoint(x: 0, y: 0)
        pauseIcon.zPosition = 5
        
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            pauseIcon.position.x = self.frame.minX / 1.48
            pauseIcon.position.y = self.frame.maxY / 1.18
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            pauseIcon.position.x = -self.frame.width / 2.7
            pauseIcon.position.y = self.frame.height / 3.25
        }
        
        self.addChild(pauseIcon)
    }
 */
    
    func initReplayButton() -> Void {
        
        replayButton = SKSpriteNode(imageNamed: "replay-button.png")
        replayButton.name = "replaybutton"
        //replayButton.color = .white
        replayButton.zPosition = 4
        //replayButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        replayShape = SKShapeNode(circleOfRadius: 60)
        replayShape.name = "replayshape"
        replayShape.isUserInteractionEnabled = false
        replayShape.fillColor = .white
        replayShape.isAntialiased = true
        replayShape.strokeColor = .black
        replayShape.lineWidth = 5
        replayShape.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        replayShape.addChild(replayButton)
        replayShape.zPosition = 3

        self.addChild(replayShape)
    }
    
    func initNextLevelButton() -> Void {
    
        nextLevelButton = SKSpriteNode(imageNamed: "next-level-icon")
        nextLevelButton.name = "nextlevelbutton"
        nextLevelButton.size = CGSize(width: nextLevelButton.size.width / 7, height: nextLevelButton.size.height / 7)
        nextLevelButton.isUserInteractionEnabled = false
        nextLevelButton.zPosition = 4
        
        nextLevelShape = SKShapeNode(circleOfRadius: 60)
        nextLevelShape.name = "nextlevelshape"
        nextLevelShape.isUserInteractionEnabled = false
        nextLevelShape.fillColor = .white
        nextLevelShape.isAntialiased = true
        nextLevelShape.strokeColor = .black
        nextLevelShape.lineWidth = 5
        nextLevelShape.position = CGPoint(x: self.frame.midX + 200, y: self.frame.midY + 50)
        nextLevelShape.addChild(nextLevelButton)
        nextLevelShape.zPosition = 3
        
        self.addChild(nextLevelShape)

    }
    
    func initHomeButton() -> Void {
        
        homeButton = SKSpriteNode(imageNamed: "home-icon.png")
        homeButton.name = "homebutton"
        homeButton.size = CGSize(width: homeButton.size.width / 7, height: homeButton.size.height / 7)
        homeButton.zPosition = 4

        homeButtonShape = SKShapeNode(circleOfRadius: 60)
        homeButtonShape.name = "homebuttonshape"
        homeButtonShape.isUserInteractionEnabled = false
        homeButtonShape.fillColor = .white
        homeButtonShape.isAntialiased = true
        homeButtonShape.strokeColor = .black
        homeButtonShape.lineWidth = 5
        homeButtonShape.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY + 50)
        homeButtonShape.addChild(homeButton)
        homeButtonShape.zPosition = 3
        
        self.addChild(homeButtonShape)
    }
    
    func initMenuButton() -> Void {
        
        menuButton = SKSpriteNode(imageNamed: "menu-icon.png")
        menuButton.name = "menubutton"
        menuButton.size = CGSize(width: menuButton.size.width / 4, height: menuButton.size.height / 4)
        menuButton.position = CGPoint(x: 21, y: 0)
        menuButton.zPosition = 4
        
        
        menuButtonShape = SKShapeNode(circleOfRadius: 60)
        menuButtonShape.name = "menubuttonshape"
        menuButtonShape.isUserInteractionEnabled = false
        menuButtonShape.fillColor = .white
        menuButtonShape.isAntialiased = true
        menuButtonShape.strokeColor = .black
        menuButtonShape.lineWidth = 5
        menuButtonShape.position = CGPoint(x: self.frame.midX + 200, y: self.frame.midY + 50)
        menuButtonShape.addChild(menuButton)
        menuButtonShape.zPosition = 5
        
        self.addChild(menuButtonShape)
        
    }

    func showEndingMenu() -> Void {
        
        gameOverDisplay = SKShapeNode(rect: CGRect(x: -self.frame.width, y: self.frame.midY - 20, width: self.frame.width * 2, height: self.frame.height / 4.5))
        gameOverDisplay.fillColor = .black
        gameOverDisplay.alpha = 0.5
                
        levelAlert = SKLabelNode(fontNamed: "CarbonBl-Regular")
        levelAlert.fontColor = .white
        levelAlert.fontSize = 72
        levelAlert.position = CGPoint(x: 0, y: 200)
        levelAlert.text = "Level " + String(levelData.currentLevel) + ":"
        
        levelStatusAlert = SKLabelNode(fontNamed: "CarbonBl-Regular")
        levelStatusAlert.fontSize = 72
        levelStatusAlert.position = CGPoint(x: 0, y: 125)
        
        if(isLevelPassed)
        {
            initNextLevelButton()
            levelStatusAlert.fontColor = .green
            levelStatusAlert.text = "PASSED"
        }

        else
        {
            initMenuButton()
            levelStatusAlert.fontColor = .red
            levelStatusAlert.text = "INCOMPLETE"
        }
        
        initReplayButton()
        initHomeButton()
        
        self.addChild(gameOverDisplay)
        self.addChild(levelAlert)
        self.addChild(levelStatusAlert)
    }

    func pauseRunning() -> Void{
                
        if(isMasked)
        {
            characterSprite.removeAction(forKey: "maskedrunning")
        }
        else
        {
            characterSprite.removeAction(forKey: "running")
        }
    }
    
    func resumeRunning() -> Void{
        
        let runAnimations: [SKTexture]
        let mainAnimated: SKAction
        let mainRepeater: SKAction
        
        if(isMasked)
        {
            runAnimations = [SKTexture(imageNamed: "masked-bobby-6.png"), SKTexture(imageNamed: "masked-bobby-7.png"), SKTexture(imageNamed: "masked-bobby-8.png"), SKTexture(imageNamed: "masked-bobby-9.png"), SKTexture(imageNamed: "masked-bobby-10.png"), SKTexture(imageNamed: "masked-bobby-11.png")]
            
            mainAnimated = SKAction.animate(with: runAnimations, timePerFrame: 0.2)
            mainRepeater = SKAction.repeatForever(mainAnimated)
            characterSprite.run(mainRepeater, withKey: "maskedrunning")
        }
        else
        {
            runAnimations = [SKTexture(imageNamed: "bobby-6.png"), SKTexture(imageNamed: "bobby-7.png"), SKTexture(imageNamed: "bobby-8.png"), SKTexture(imageNamed: "bobby-9.png"), SKTexture(imageNamed: "bobby-10.png"), SKTexture(imageNamed: "bobby-11.png")]
            
            mainAnimated = SKAction.animate(with: runAnimations, timePerFrame: 0.2)
            mainRepeater = SKAction.repeatForever(mainAnimated)
            characterSprite.run(mainRepeater, withKey: "running")
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
            default:
                break
            }
    
        }
    }
    
    @objc func jumpUp() {
                
        if(!isReady())
        {
            print("Cooldown on button")
            return
        }
        
        pauseRunning()
        characterSprite.removeAllActions()
        
        if(game.contactDetected)
        {
            return
        }
        else
        {
            jumpCharacter()
        }
    }
    
    @objc func slideDown() {
                
        if(!isReady())
        {
            print("Cooldown on button")
            return
        }
        pauseRunning()
        
        if(!game.contactDetected)
        {
            duckCharacter()
        }
    }

    func drawCharacter() -> Void{
        
        let runAnimations:[SKTexture] = [SKTexture(imageNamed: "bobby-6.png"), SKTexture(imageNamed: "bobby-7.png"), SKTexture(imageNamed: "bobby-8.png"), SKTexture(imageNamed: "bobby-9.png"), SKTexture(imageNamed: "bobby-10.png"), SKTexture(imageNamed: "bobby-11.png")]
        
        let mainAnimated = SKAction.animate(with: runAnimations, timePerFrame: 0.2)
        let mainRepeater = SKAction.repeatForever(mainAnimated)
        
        characterSprite = SKSpriteNode(imageNamed: "bobby-6.png")
        characterSprite.name = "character"
        characterSprite.position = CGPoint(x: self.frame.minX / 2.35, y: self.frame.minY / 1.70)
        characterSprite.size = CGSize(width: characterSprite.size.width / 2, height: characterSprite.size.height / 2)
        characterSprite.color = .black
        characterSprite.colorBlendFactor = 0.1
        characterSprite.zPosition = 2;
        
        
        //Physics Body
        characterSprite.physicsBody = SKPhysicsBody(circleOfRadius: characterSprite.size.width / 2.5)
        characterSprite.physicsBody?.affectedByGravity = false
        characterSprite.physicsBody?.categoryBitMask = ColliderType.character
        characterSprite.physicsBody?.collisionBitMask = ColliderType.soap
        characterSprite.physicsBody?.isDynamic = true
        
        
        self.addChild(characterSprite)
        characterSprite.run(mainRepeater, withKey: "running")
    }
    
    func charMoveToPortal() {
        
        pauseBackgAndPlatform()
        
        let xShift = SKAction.moveTo(x: portal.position.x - 100, duration: bgAnimatedInSecs / 8)
        
        let xRepeater = SKAction.repeat(xShift, count: 1)
        
        characterSprite.run(xRepeater, completion: charEndAnimation)
        
    }
    
    func charEndAnimation() {
        
        isLevelPassed = true
        
        let charShift = SKAction.moveTo(x: portal.position.x + 10, duration: bgAnimatedInSecs / 4)
        let yRise = SKAction.moveTo(y: portal.position.y + 10, duration: bgAnimatedInSecs / 8)
        let rotation = SKAction.rotate(toAngle: -(2 * CGFloat.pi), duration: bgAnimatedInSecs / 8)
        let reversion = SKAction.rotate(toAngle: 0, duration: 0)
        
        let rotationSeq = SKAction.sequence([rotation, reversion])
        
        let charRepeater = SKAction.repeat(charShift, count: 1)
        let yRepeater = SKAction.repeatForever(yRise)
        let rotationRepeater = SKAction.repeatForever(rotationSeq)
        
        characterSprite.removeAction(forKey: "running")
        characterSprite.run(charRepeater)
        characterSprite.run(yRepeater)
        characterSprite.run(rotationRepeater)
        
    }
    
    func drawPortal() {
        
        self.view?.gestureRecognizers?.removeAll()
        let portalShift = SKAction.moveTo(x: self.frame.width / 3, duration: bgAnimatedInSecs / 2)
        let portalRepeater = SKAction.repeat(portalShift, count: 1)
        
        portal.run(portalRepeater, completion: charMoveToPortal)
    }
    
    func addGlitterEffect() {
        
        let endRange = Int(game.charInitialPos.y + 101)
        let randY = Int.random(in: Int(game.charInitialPos.y) ..< endRange)
        
        glitter.position.y = CGFloat(randY)
        
        let xShift = SKAction.moveTo(x: -self.frame.width, duration: bgAnimatedInSecs)
        let xReversion = SKAction.moveTo(x: self.frame.width, duration: 0)
        let xSequencer = SKAction.sequence([xShift, xReversion])
        let xRepeater = SKAction.repeat(xSequencer, count: 1)
        
        glitter.run(xRepeater)
    }
    
    func addSoap() {
        
        temp += 1
        soap.isHidden = false
        
        addGlitterEffect()
        
        glitter.position.x = self.frame.width
        
        if(temp == 1)
        {
            let fullRotation = SKAction.rotate(byAngle: (2 * CGFloat.pi), duration: bgAnimatedInSecs / 2)
            let rotationRepeater = SKAction.repeatForever(fullRotation)
            soap.run(rotationRepeater)
        }
    }
    
    func drawBat1() {
        
        let batFrames: [SKTexture] = [SKTexture(imageNamed: "batframe-1"), SKTexture(imageNamed: "batframe-2"), SKTexture(imageNamed: "batframe-3"), SKTexture(imageNamed: "batframe-4")]
        
        let batAnim = SKAction.animate(with: batFrames, timePerFrame: 0.2)
        let batAnimRepeater = SKAction.repeatForever(batAnim)
        let batShift = SKAction.move(to: CGPoint(x: -self.frame.width * 2, y: batSprite.position.y), duration: bgAnimatedInSecs / 1.25)
        
        batSprite.isHidden = false
        
        batSprite.run(batAnimRepeater)
        batSprite2.run(batAnimRepeater)
        batSprite3.run(batAnimRepeater)
        
        batSprite.run(batShift, completion: batReversion)
    }
    
    func batReversion() -> Void {
        
        batSprite.xScale = 1
        let batReversion = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: self.frame.maxY / 2), duration: bgAnimatedInSecs)
        batSprite.run(batReversion)
    }
    
    func bat2Reversion() -> Void {
        
        batSprite2.xScale = 1
        let batReversion = SKAction.move(to: CGPoint(x: characterSprite.position.x - 100, y: self.frame.maxY / 3), duration: bgAnimatedInSecs)
        batSprite2.run(batReversion)
    }
    
    func bat3Reversion() -> Void {
        
        batSprite3.xScale = 1
        let batReversion = SKAction.move(to: CGPoint(x: characterSprite.position.x + 100, y: self.frame.maxY / 3), duration: bgAnimatedInSecs)
        batSprite3.run(batReversion)
    }
    
    
    func drawBat2() {
        
        batSprite2.isHidden = false
        
        let batShift = SKAction.move(to: CGPoint(x: -self.frame.width * 2, y: batSprite2.position.y), duration: bgAnimatedInSecs / 1.25)

        batSprite2.run(batShift, completion: bat2Reversion)
    }
    
    func drawBat3() {
        
        batSprite3.isHidden = false
        
        let batShift = SKAction.move(to: CGPoint(x: -self.frame.width * 2, y: batSprite3.position.y), duration: bgAnimatedInSecs / 1.25)

        batSprite3.run(batShift, completion: bat3Reversion)
    }
       
    
    func jumpCharacter() -> Void{
                
        if(game.contactDetected)
        {
            return
        }
        
        characterSprite.removeAllActions()
        let upAction = SKAction.move(to: CGPoint(x: self.frame.minX / 2.35, y: self.frame.minY / 12), duration: 0.5)
        let upRepeater = SKAction.repeat(upAction, count: 1)
        
        if(isMasked)
        {
            characterSprite.texture = SKTexture(imageNamed: "masked-bobby-12.png")
        }
        else
        {
            characterSprite.texture = SKTexture(imageNamed: "bobby-12.png")
        }
        characterSprite.run(upRepeater, completion: jumpLanding)
    }
    
    func jumpLanding() {
        
        if(characterSprite.physicsBody?.isDynamic == false)
        {
            characterSprite.physicsBody?.isDynamic = true
        }
        
        let downAction = SKAction.move(to: CGPoint(x: self.frame.minX / 2.35, y: self.frame.minY / 1.70), duration: 0.5)
        let downRepeater = SKAction.repeat(downAction, count: 1)

        if(isMasked)
        {
            characterSprite.texture = SKTexture(imageNamed: "masked-bobby-13.png")
        }
        else
        {
            characterSprite.texture = SKTexture(imageNamed: "bobby-13.png")
        }
        
        characterSprite.run(downRepeater, completion: resumeRunning)
    }
    
    func duckCharacter() -> Void {
        
        let duckFrames: [SKTexture]
        
        characterSprite.removeAllActions()

        if(isMasked)
        {
            duckFrames = [SKTexture(imageNamed: "masked-bobby-5.png")]
        }
        else
        {
            duckFrames = [SKTexture(imageNamed: "bobby-5.png")]
        }
                        
       let duckAnimation = SKAction.animate(with: duckFrames, timePerFrame: 0.25)
       let yShift = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: characterSprite.position.y - 15), duration: 0.5)
        
       let repeatDuck = SKAction.repeat(duckAnimation, count: 1)
       let repeatYShift = SKAction.repeat(yShift, count: 1)

       characterSprite.run(repeatDuck)
       characterSprite.run(repeatYShift, completion: duckRevert)
    }
    
    func duckRevert() {
        
        let yRevert = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: characterSprite.position.y + 15), duration: 0.3)
        
        let repeatYRevert = SKAction.repeat(yRevert, count: 1)
        
        characterSprite.run(repeatYRevert, completion: resumeRunning)
    }
    
    func initObjects() -> Void{
        
         /*
         tapToContinue = SKLabelNode(fontNamed: "Balibold-Regular")
         tapToContinue.fontColor = .white
         tapToContinue.fontSize = 30
         tapToContinue.text = "Click to continue"
         tapToContinue.position = CGPoint(x: 0, y: 0)
         tapToContinue.alpha = 1
         
         tapToContinue.isHidden = true
         self.addChild(tapToContinue)
         
        
        pauseDisplay = SKShapeNode(rect: CGRect(x: -self.frame.width, y: self.frame.midY - 20 + (self.frame.height / 4.5), width: self.frame.width * 2, height: -self.frame.height / 8))
        pauseDisplay.fillColor = .black
        pauseDisplay.alpha = 0.5
                
        pauseLevelDisplay = SKLabelNode(fontNamed: "CarbonBl-Regular")
        pauseLevelDisplay.fontColor = .white
        pauseLevelDisplay.fontSize = 72
        pauseLevelDisplay.position = CGPoint(x: 0, y: 200)
        pauseLevelDisplay.text = "Level Beta:"
        
        pauseStatus = SKLabelNode(fontNamed: "CarbonBl-Regular")
        pauseStatus.text = "PAUSED"
        pauseStatus.fontColor = .gray
        pauseStatus.fontSize = 72
        pauseStatus.position = CGPoint(x: 0, y: 125)
        
        self.addChild(pauseDisplay)
        pauseDisplay.isHidden = true
        self.addChild(pauseLevelDisplay)
        pauseLevelDisplay.isHidden = true
        self.addChild(pauseStatus)
        pauseStatus.isHidden = true
 */
        
        portal = SKSpriteNode(imageNamed: "blueportal.png")
        portal.xScale = -1
        portal.position = CGPoint(x: self.frame.width, y: game.charInitialPos.y + 150)
        portal.size = CGSize(width: portal.size.width / 1.5, height: portal.size.height / 1.5)
        portal.name = "portal"
       
        //Physics Body

        portal.physicsBody = SKPhysicsBody(circleOfRadius: portal.size.width / 6)
        portal.physicsBody?.affectedByGravity = false
        portal.physicsBody?.categoryBitMask = ColliderType.portal
        portal.physicsBody?.collisionBitMask = ColliderType.character
        portal.physicsBody?.contactTestBitMask = ColliderType.character
        portal.physicsBody?.usesPreciseCollisionDetection = true
        portal.physicsBody?.isDynamic = false
       
        self.addChild(portal)
        
        
        //Mask
        
        mask = SKSpriteNode(imageNamed: "mask.png")
        mask.name = "mask"
        mask.position = CGPoint(x: self.frame.width, y: game.charInitialPos.y)
        mask.size = CGSize(width: mask.size.width / 8, height: mask.size.height / 8)
        mask.zPosition = 5
        
        mask.physicsBody = SKPhysicsBody(circleOfRadius: mask.size.width / 2)
        mask.physicsBody?.affectedByGravity = false
        mask.physicsBody?.categoryBitMask = ColliderType.mask
        mask.physicsBody?.collisionBitMask = ColliderType.character
        mask.physicsBody?.contactTestBitMask = ColliderType.character
        mask.physicsBody?.isDynamic = false
        self.addChild(mask)
        
        //Zombies
        
        blondeZombie = SKSpriteNode(imageNamed: "blondezombie-1.png")
        
        blondeZombie.lightingBitMask = 50
        blondeZombie.xScale = -1
        blondeZombie.size = CGSize(width: blondeZombie.size.width, height: blondeZombie.size.height)
        game.zombieInitialSize = blondeZombie.size
        blondeZombie.position = CGPoint(x: self.size.width, y: game.charInitialPos.y)
        blondeZombie.zPosition = 4
        
        self.addChild(blondeZombie)
        
        redZombie = SKSpriteNode(imageNamed: "redzombie-1.png")
        redZombie.position = CGPoint(x: self.size.width, y: game.charInitialPos.y)

        redZombie.lightingBitMask = 50
        redZombie.xScale = -1
        redZombie.size = CGSize(width: redZombie.size.width, height: redZombie.size.height)
        redZombie.zPosition = 4
        
        self.addChild(redZombie)
        
        //Exclamation
        exclamationMark = SKSpriteNode(imageNamed: "exclamation.png")
        exclamationMark.zPosition = 5
        exclamationMark.size = CGSize(width: exclamationMark.size.width / 1.25, height: exclamationMark.size.height / 1.25)
        
        exclamationShape = SKShapeNode(circleOfRadius: exclamationMark.size.width / 2)
        exclamationShape.fillColor = .clear
        exclamationShape.strokeColor = .clear
        exclamationShape.lineWidth = 5
        exclamationShape.isAntialiased = true
        exclamationShape.addChild(exclamationMark)
        exclamationShape.zPosition = 4
        exclamationShape.alpha = 0.0
        
        self.addChild(exclamationShape)
        
        //BananaPeel
        bananaPeel = SKSpriteNode(imageNamed: "banana-peel.png")
        bananaPeel.size = CGSize(width: characterSprite.size.width / 1.5, height: characterSprite.size.height / 1.5)
        bananaPeel.position = CGPoint(x: self.frame.size.width, y: self.frame.minX * 1.15)
        bananaPeel.zPosition = 3
        bananaPeel.name = "banana"
       
        bananaPeel.physicsBody = SKPhysicsBody(circleOfRadius: bananaPeel.size.width / 2)
        bananaPeel.physicsBody?.affectedByGravity = false
        bananaPeel.physicsBody?.categoryBitMask = ColliderType.banana
        bananaPeel.physicsBody?.collisionBitMask = ColliderType.character
        bananaPeel.physicsBody?.contactTestBitMask = ColliderType.character
        bananaPeel.physicsBody?.isDynamic = false
        
        self.addChild(bananaPeel)
        
        //Germs
        blueGerms = SKEmitterNode(fileNamed: "sneezeblue.sks")!
        blueGerms.name = "bluegerms"
        blueGerms.zPosition = 3
        blueGerms.position = CGPoint(x: self.frame.width, y: characterSprite.position.y)
        blueGerms.isHidden = true
        
        blueGerms.physicsBody = SKPhysicsBody(circleOfRadius: 65, center: CGPoint(x: -60, y: 0))
        blueGerms.physicsBody?.affectedByGravity = false
        blueGerms.physicsBody?.categoryBitMask = ColliderType.bluegerms
        blueGerms.physicsBody?.collisionBitMask = ColliderType.character
        blueGerms.physicsBody?.contactTestBitMask = ColliderType.character
        blueGerms.physicsBody?.isDynamic = false
    
        self.addChild(blueGerms)
        
        greenGerms = SKEmitterNode(fileNamed: "sneezegreen.sks")!
        greenGerms.name = "greengerms"
        greenGerms.zPosition = 3
        greenGerms.position = CGPoint(x: self.frame.width, y: characterSprite.position.y)
        greenGerms.isHidden = true
        
        greenGerms.physicsBody = SKPhysicsBody(circleOfRadius: 75)
        greenGerms.physicsBody?.affectedByGravity = false
        greenGerms.physicsBody?.categoryBitMask = ColliderType.greengerms
        greenGerms.physicsBody?.collisionBitMask = ColliderType.character
        greenGerms.physicsBody?.contactTestBitMask = ColliderType.character
        greenGerms.physicsBody?.isDynamic = false
        
        self.addChild(greenGerms)
        
        //Soap/Glitter
        soap = SKSpriteNode(imageNamed: "hand-sanitizer.png")
        soap.name = "soap"
        soap.size = CGSize(width: soap.size.width / 6, height: soap.size.height / 6)
        soap.zPosition = 4
        soap.physicsBody = SKPhysicsBody(circleOfRadius: soap.size.height / 2)
        soap.physicsBody?.affectedByGravity = false
        soap.physicsBody?.categoryBitMask = ColliderType.soap
        soap.physicsBody?.collisionBitMask = ColliderType.character
        soap.physicsBody?.contactTestBitMask = ColliderType.character
        soap.physicsBody?.usesPreciseCollisionDetection = true
        soap.physicsBody?.isDynamic = false
        
        glitter = SKEmitterNode(fileNamed: "shimmer.sks")!
        glitter.zPosition = 3
        glitter.position = CGPoint(x: self.frame.width, y: -250)
        
        glitter.addChild(soap)
        self.addChild(glitter)
        
        //Bats
        batSprite = SKSpriteNode(imageNamed: "batframe-1.png")
        batSprite2 = SKSpriteNode(imageNamed: "batframe-1.png")
        batSprite3 = SKSpriteNode(imageNamed: "batframe-1.png")

        batSprite.position = CGPoint(x: self.frame.width, y: game.charInitialPos.y + 95)
        batSprite.size = CGSize(width: batSprite.size.width / 1.75, height: batSprite.size.height / 1.75)
        batSprite.name = "bat"
        batSprite.xScale = -1
        batSprite.zPosition = 2
        batSprite.physicsBody = SKPhysicsBody(circleOfRadius: batSprite.size.width / 3)
        batSprite.physicsBody?.affectedByGravity = false
        batSprite.physicsBody?.categoryBitMask = ColliderType.bat
        batSprite.physicsBody?.collisionBitMask = ColliderType.character
        batSprite.physicsBody?.contactTestBitMask = ColliderType.character
        batSprite.physicsBody?.usesPreciseCollisionDetection = true
        batSprite.physicsBody?.isDynamic = false
        
        batSprite2.position = CGPoint(x: self.frame.width, y: game.charInitialPos.y + 95)
        batSprite2.size = CGSize(width: batSprite2.size.width / 1.75, height: batSprite2.size.height / 1.75)
        batSprite2.name = "bat"
        batSprite2.xScale = -1
        batSprite2.zPosition = 2
        batSprite2.physicsBody = SKPhysicsBody(circleOfRadius: batSprite2.size.width / 3)
        batSprite2.physicsBody?.affectedByGravity = false
        batSprite2.physicsBody?.categoryBitMask = ColliderType.bat
        batSprite2.physicsBody?.collisionBitMask = ColliderType.character
        batSprite2.physicsBody?.contactTestBitMask = ColliderType.character
        batSprite2.physicsBody?.usesPreciseCollisionDetection = true
        batSprite2.physicsBody?.isDynamic = false
        
        batSprite3.position = CGPoint(x: self.frame.width, y: game.charInitialPos.y + 95)
        batSprite3.size = CGSize(width: batSprite3.size.width / 1.75, height: batSprite3.size.height / 1.75)
        batSprite3.name = "bat"
        batSprite3.xScale = -1
        batSprite3.zPosition = 2
        batSprite3.physicsBody = SKPhysicsBody(circleOfRadius: batSprite3.size.width / 3)
        batSprite3.physicsBody?.affectedByGravity = false
        batSprite3.physicsBody?.categoryBitMask = ColliderType.bat
        batSprite3.physicsBody?.collisionBitMask = ColliderType.character
        batSprite3.physicsBody?.contactTestBitMask = ColliderType.character
        batSprite3.physicsBody?.usesPreciseCollisionDetection = true
        batSprite3.physicsBody?.isDynamic = false
        
        miniCharacter = SKSpriteNode(imageNamed: "(b)obby-1.png")
        self.addChild(miniCharacter)
        levelDisplay = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        self.addChild(levelDisplay)
        levelDisplayShape = SKShapeNode(rect: CGRect(x: (-self.frame.width), y: 0, width: (2 * self.frame.width), height: self.frame.height / 8))
        self.addChild(levelDisplayShape)
        livesDisplay = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        self.addChild(livesDisplay)
        
        self.addChild(batSprite)
        self.addChild(batSprite2)
        self.addChild(batSprite3)
        
        batSprite.isHidden = true
        batSprite2.isHidden = true
        batSprite3.isHidden = true
    }
    
    func drawRedZombie() {
        
        let zombieSneezeFrames: [SKTexture] = [SKTexture(imageNamed: "redzombie-1.png"), SKTexture(imageNamed: "redzombie-2.png"), SKTexture(imageNamed: "redzombie-3.png"), SKTexture(imageNamed: "redzombie-4.png")]
        
        let zombieAnim = SKAction.animate(with: zombieSneezeFrames, timePerFrame: 0.28)
        let zombieShift = SKAction.moveTo(x: -self.size.width, duration: bgAnimatedInSecs * 1.1)
        
        let animRepeater = SKAction.repeat(zombieAnim, count: 1)
        let shiftRepeater = SKAction.repeat(zombieShift, count: 1)
        
        redZombie.run(animRepeater, completion: pauseRedZombie)
        redZombie.run(shiftRepeater)
    }
    
    func drawBlondeZombie() {
        
        let zombieSneezeFrames: [SKTexture] = [SKTexture(imageNamed: "blondezombie-1.png"), SKTexture(imageNamed: "blondezombie-2.png"), SKTexture(imageNamed: "blondezombie-3.png"), SKTexture(imageNamed: "blondezombie-4.png")]
        
        let zombieAnim = SKAction.animate(with: zombieSneezeFrames, timePerFrame: 0.28)
        let zombieShift = SKAction.moveTo(x: -self.size.width, duration: bgAnimatedInSecs * 1.1)
        
        let animRepeater = SKAction.repeat(zombieAnim, count: 1)
        let shiftRepeater = SKAction.repeat(zombieShift, count: 1)
        
       
        blondeZombie.run(animRepeater, completion: pauseBlondeZombie)
        blondeZombie.run(shiftRepeater)
    }
    
    func pauseRedZombie() {
        
        redZombie.removeAllActions()
        //drawExclamation(zombie: redZombie)
        redZombie.texture = SKTexture(imageNamed: "redzombie-4.png")
        
        let zombieSneezeFrames: [SKTexture] = [SKTexture(imageNamed: "redzombie-4.png"), SKTexture(imageNamed: "redzombie-5.png")]
        
        let sneezeAnim = SKAction.animate(with: zombieSneezeFrames, timePerFrame: 0.15)
        
        let sneezeRepeater = SKAction.repeat(sneezeAnim, count: 1)
        
        playSneezeSound()
        redZombie.run(sneezeRepeater, completion: redZombieDieAnim)
    }
    
    func pauseBlondeZombie() {
        
        blondeZombie.removeAllActions()
        //drawExclamation(zombie: blondeZombie)
        blondeZombie.texture = SKTexture(imageNamed: "blondezombie-4.png")
        
        let zombieSneezeFrames: [SKTexture] = [SKTexture(imageNamed: "blondezombie-4.png"), SKTexture(imageNamed: "blondezombie-5.png")]
        
        let sneezeAnim = SKAction.animate(with: zombieSneezeFrames, timePerFrame: 0.15)

        let sneezeRepeater = SKAction.repeat(sneezeAnim, count: 1)
        
        playSneezeSound()
        blondeZombie.run(sneezeRepeater, completion: blondeZombieDieAnim)
    }
    
    func drawExclamation(zombie: SKSpriteNode) {

        exclamationShape.position = CGPoint(x: zombie.position.x, y: zombie.position.y + 150)

        let exclamationFadeIn = SKAction.fadeIn(withDuration: bgAnimatedInSecs / 12)
        let exclamationFadeOut = SKAction.fadeOut(withDuration: bgAnimatedInSecs / 12)
        
        let exclamationSeq = SKAction.sequence([exclamationFadeIn, exclamationFadeOut])
        
        let exclamationTransRepeater = SKAction.repeat(exclamationSeq, count: 1)
        
        exclamationShape.run(exclamationTransRepeater)
    }
    
    func redZombieDieAnim() {
        
        let endRange = Int(game.charInitialPos.y) + 250
        let randY = Int.random(in: Int(game.charInitialPos.y) ..< endRange)
        
        let yShift = SKAction.moveTo(y: CGFloat(randY), duration: 0.1)
        let rotation = SKAction.rotate(byAngle: -(2 * CGFloat.pi), duration: bgAnimatedInSecs / 4)
        let minimize = SKAction.resize(toWidth: 0, height: 0, duration: bgAnimatedInSecs / 4)
        
        let yRepeater = SKAction.repeat(yShift, count: 1)
        let rotationRepeater = SKAction.repeat(rotation, count: 1)
        let minimizeRepeater = SKAction.repeat(minimize, count: 1)
        
        redZombie.run(rotationRepeater)
        greenGerms.run(yRepeater, completion: shiftGreenGerms)
        redZombie.run(minimizeRepeater)
        
        greenGerms.position = redZombie.position
        
        greenGerms.isHidden = false
    }
    
    func blondeZombieDieAnim() {
        
        let endRange = Int(game.charInitialPos.y) + 250
        let randY = Int.random(in: Int(game.charInitialPos.y) ..< endRange)
        
        let yShift = SKAction.moveTo(y: CGFloat(randY), duration: 0.1)
        let rotation = SKAction.rotate(byAngle: -(2 * CGFloat.pi), duration: bgAnimatedInSecs / 4)
        let minimize = SKAction.resize(toWidth: 0, height: 0, duration: bgAnimatedInSecs / 4)
        
        let yRepeater = SKAction.repeat(yShift, count: 1)
        let rotationRepeater = SKAction.repeat(rotation, count: 1)
        let minimizeRepeater = SKAction.repeat(minimize, count: 1)
        
        blondeZombie.run(rotationRepeater)
        blueGerms.run(yRepeater, completion: shiftBlueGerms)
        blondeZombie.run(minimizeRepeater)
        
        blueGerms.position = blondeZombie.position
        
        blueGerms.isHidden = false
    }
    
    func shiftBlueGerms() {
        
        let germShift = SKAction.moveTo(x: -self.size.width, duration: bgAnimatedInSecs / 1.8)
        let germReversion = SKAction.moveTo(x: self.size.width, duration: 0)
        
        let germSeq = SKAction.sequence([germShift, germReversion])
        
        let germShiftRepeater = SKAction.repeat(germSeq, count: 1)
        
        blueGerms.run(germShiftRepeater, completion: revertBlondeZombie)
    }
    
    func revertBlondeZombie() {
        
        let resizeReversion = SKAction.resize(toWidth: game.zombieInitialSize.width, height: game.zombieInitialSize.height, duration: 0)
        let shiftReversion = SKAction.moveTo(x: self.frame.width, duration: 0)
        
        let resizeRepeater = SKAction.repeat(resizeReversion, count: 1)
        let shiftRepeater = SKAction.repeat(shiftReversion, count: 1)
        
        blondeZombie.run(resizeRepeater)
        blondeZombie.run(shiftRepeater)
    }
    
    func revertRedZombie() {
        
        let resizeReversion = SKAction.resize(toWidth: game.zombieInitialSize.width, height: game.zombieInitialSize.height, duration: 0)
        let shiftReversion = SKAction.moveTo(x: self.frame.width, duration: 0)
        
        let resizeRepeater = SKAction.repeat(resizeReversion, count: 1)
        let shiftRepeater = SKAction.repeat(shiftReversion, count: 1)
        
        redZombie.run(resizeRepeater)
        redZombie.run(shiftRepeater)
    }
    
    func shiftGreenGerms() {
        
        let germShift = SKAction.moveTo(x: -self.size.width, duration: bgAnimatedInSecs / 1.8)
        let germReversion = SKAction.moveTo(x: self.size.width, duration: 0)
        
        let germSeq = SKAction.sequence([germShift, germReversion])
        
        let germShiftRepeater = SKAction.repeat(germSeq, count: 1)
        
        greenGerms.run(germShiftRepeater, completion: revertRedZombie)
    }
    
    func drawPeel() -> Void {
        
        bananaPeel.isHidden = false
        let peelShift = SKAction.move(by: CGVector(dx: -self.frame.size.width * 2, dy: 0), duration: bgAnimatedInSecs / 1.75)
        //let peelSequence = SKAction.sequence([peelShift, peelReversion])
        let peelAnimation = SKAction.repeat(peelShift, count: 1)
                
        bananaPeel.run(peelAnimation, completion: revertPeel)
    }
    
    func revertPeel() {
        
        let peelReversion = SKAction.move(by: CGVector(dx: self.frame.size.width * 2, dy: 0), duration: 0)
        let peelRevert = SKAction.repeat(peelReversion, count: 1)
        
        bananaPeel.run(peelRevert)
        bananaPeel.isHidden = true
        
    }
    
    func peelDieAnimation() -> Void {

        self.view?.gestureRecognizers?.removeAll()
        bananaPeel.removeAllActions()
        characterSprite.removeAllActions()
        
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-15.png")
        
        
        let bananaSlide = SKAction.move(to: CGPoint(x: self.frame.size.width * 2, y: self.frame.minX * 1.15), duration: 0.5)
        
        let rotation = SKAction.rotate(byAngle: ((3 * CGFloat.pi) / 2), duration: 0.3)
        
        
        let bananaSlideAnim = SKAction.repeat(bananaSlide, count: 1)
        let rotationAnim = SKAction.repeat(rotation, count: 1)
                
        characterSprite.run(rotationAnim)
        bananaPeel.run(bananaSlideAnim, completion: rotateBack)
    }
    
    func rotateBack() {
        
        let rotationBack = SKAction.rotate(byAngle: (-(3 * CGFloat.pi) / 2), duration: 0)
        let fall = SKAction.move(to: CGPoint(x: self.frame.minX / 2.35, y: self.frame.minY / 1.70), duration: 0.3)
        
        let rotationBackAnim = SKAction.repeat(rotationBack, count: 1)
        let fallAnim = SKAction.repeat(fall, count: 1)
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-16.png")
        characterSprite.run(rotationBackAnim)
        characterSprite.run(fallAnim, completion: endGame)
    }
    
    func batDieAnimation() {
        
        self.view?.gestureRecognizers?.removeAll()
        characterSprite.removeAllActions()
        
        let rotation = SKAction.rotate(byAngle: ((3 * CGFloat.pi) / 2), duration: 0.3)
        
        let rotationAnim = SKAction.repeat(rotation, count: 1)
        
        characterSprite.run(rotationAnim, completion: rotateBack)
    }
    
    func germDieAnimation(germ: SKEmitterNode) -> Void {
        
        germ.removeAllActions()
        characterSprite.removeAllActions()
        characterSprite.texture = SKTexture(imageNamed: "bobby-15.png")
        
        let germAttraction = SKAction.move(to: CGPoint(x: germ.position.x, y: germ.position.y), duration: bgAnimatedInSecs / 6)
        let spinAnim = SKAction.rotate(byAngle: -(2 * CGFloat.pi), duration: 0.3)
        
        let germAttractionRepeater = SKAction.repeat(germAttraction, count: 1)
        let spinRepeater = SKAction.repeat(spinAnim, count: 1)
        
        characterSprite.run(germAttractionRepeater)
        characterSprite.run(spinRepeater, completion: disappearCharacter)
    }
    
    
    func disappearCharacter() {
        
        characterSprite.removeAllActions()
        characterSprite.isHidden = true
        endGame()
    }
    
    /*
    func showPauseMenu() {
        
        gameIsPaused = true
        pauseDisplay.isHidden = false
        pauseLevelDisplay.isHidden = false
        pauseStatus.isHidden = false
        
        showClickToContinue()
    }
    
    func showClickToContinue() {
        
         
         let fadeIn = SKAction.fadeIn(withDuration: 1)
         let fadeOut = SKAction.fadeOut(withDuration: 1)
        
         let fadeSequence = SKAction.sequence([fadeIn, fadeOut])
         
         let fadeForever = SKAction.repeatForever(fadeSequence)
        
         tapToContinue.isHidden = false
         tapToContinue.run(fadeForever)
    }
 */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            /*
            if(node?.name == "pausebutton")
            {
                if(gameIsPaused)
                {
                    return
                }
                else
                {
                    print("pause-button pressed")
                    let scale = SKAction.scale(to: 0.9, duration: 0.3)
                    pauseGame()
                    pauseIcon.run(scale, completion: showPauseMenu)
                }
            }
 */

            if(game.IsOver == true)
            {
                if((node?.name == "replaybutton") || (node?.name == "replayshape"))
                {
                    print("replay-button pressed")
                    let scale = SKAction.scale(to: 0.9, duration: 0.3)
                    levelData.pressedReplay = true
                    replayShape.run(scale, completion: startGame)
                }
                
                else if((node?.name == "homebutton") || (node?.name == "homeshape")) {
                    
                    if(isLevelPassed)
                    {
                        print("home button")
                        levelData.currentLevel += 1
                    }
                    
                    print("home-button pressed")
                    let scale2 = SKAction.scale(to: 0.9, duration: 0.3)
                    homeButtonShape.run(scale2, completion: goToHomeScene)
                }
                
                else if((node?.name == "menubutton") || (node?.name == "menubuttonshape")) {
                    
                    print("menu-button pressed")
                    let scale3 = SKAction.scale(to: 0.9, duration: 0.3)
                    menuButtonShape.run(scale3, completion: goToMenuScene)
                }
                
                else if((node?.name == "nextlevelbutton") || (node?.name == "nextlevelshape"))
                {
                    print("next-level pressed")
                    let scale4 = SKAction.scale(to: 0.9, duration: 0.3)
                    levelData.pressedNext = true
                    if(levelData.currentLevel == 5)
                    {
                        levelData.hasMastered = true
                        goToMenuScene()
                    }
                    else
                    {
                        levelData.currentLevel += 1
                        nextLevelShape.run(scale4, completion: startGame)
                    }
                }

            }
        }
    }
        
    func goToHomeScene() {
        
        game.contactDetected = false
        game.IsOver = false
        cleanUp()
        let homeScene = HomeScene(fileNamed: "HomeScene")
        homeScene?.scaleMode = .aspectFill
        self.view?.presentScene(homeScene)
    }
    
    func goToMenuScene() {
        
        game.contactDetected = false
        game.IsOver = false
        levelData.didLoadFromHome = false
        cleanUp()
        let menuScene = MenuScene(fileNamed: "MenuScene")
        menuScene?.scaleMode = .aspectFill
        self.view?.presentScene(menuScene)
    }
    
    
    func startGame() -> Void{
        
        cleanUp()
        initializeGame()
        self.speed = 1
        game.contactDetected = false
        game.IsOver = false
    }
    
     func endGame() -> Void{
        
        print("Current level is: " + String(levelData.currentLevel))
        print("Reached level is: " + String(levelData.reachedLevel))
        
        if(!isLevelPassed)
        {
            let bat1ToOffscreen = SKAction.move(to: CGPoint(x: -self.frame.width, y: self.frame.maxY), duration: bgAnimatedInSecs / 9)
            let bat2ToOffscreen = SKAction.move(to: CGPoint(x: 0, y: self.frame.maxY * 2), duration: bgAnimatedInSecs / 9)
            let bat3ToOffscreen = SKAction.move(to: CGPoint(x: self.frame.width, y: self.frame.maxY), duration: bgAnimatedInSecs / 9)
                   
                
            let bat1Movement = SKAction.repeat(bat1ToOffscreen, count: 1)
            let bat2Movement = SKAction.repeat(bat2ToOffscreen, count: 1)
            let bat3Movement = SKAction.repeat(bat3ToOffscreen, count: 1)
            
            batSprite.run(bat1Movement)
            batSprite2.run(bat2Movement)
            batSprite3.run(bat3Movement)
        }
         
        GameScene.defaults.set(levelData.handSanitizerCount, forKey: "handsanitizer")
        timer.invalidate()
        self.showEndingMenu()
        pauseBackgAndPlatform()
        temp = 0
        if(!isLevelPassed)
        {
            isLevelPassed = false
        }
        game.IsOver = true
    }
    
    func cleanUp() -> Void {
        
        let children = self.children
        
        for child in children
        {
            if(!child.isEqual(to: cameraNode))
            {
                child.removeAllActions()
            }
        }
        self.removeAllChildren()
    }
    
    func pauseBackgAndPlatform() {
        
        for child in cameraNode.children
        {
            if((child.name == "background0") || (child.name == "background1"))
            {
                child.speed = 0
            }
            
            if((child.name == "platform0") || (child.name == "platform1"))
            {
                child.speed = 0
            }
        }
    }
    
    func pauseAllObjects() {
        
        bananaPeel.isPaused = true
        redZombie.isPaused = true
        blondeZombie.isPaused = true
        batSprite.isPaused = true
        batSprite2.isPaused = true
        batSprite3.isPaused = true
        blueGerms.isPaused = true
        greenGerms.isPaused = true
        soap.isPaused = true
        glitter.isPaused = true
        mask.isPaused = true
    }
    
    func resumeAllObjects() {
        
        bananaPeel.isPaused = false
        redZombie.isPaused = false
        blondeZombie.isPaused = false
        batSprite.isPaused = false
        batSprite2.isPaused = false
        batSprite3.isPaused = false
        blueGerms.isPaused = false
        greenGerms.isPaused = false
        soap.isPaused = false
        glitter.isPaused = false
        mask.isPaused = false
    }
    
    func resumeGame() {
        
        resumeAllObjects()
        characterSprite.isPaused = false
        for child in cameraNode.children
        {
            if((child.name == "background0") || (child.name == "background1"))
            {
                child.isPaused = false
            }
            
            if((child.name == "platform0") || (child.name == "platform1"))
            {
                child.isPaused = false
            }
        }
    }
}
