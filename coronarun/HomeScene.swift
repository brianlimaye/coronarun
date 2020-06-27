//
//  HomeScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/31/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//
//1. Try to add characters that cough/sneeze.
//2. Pick up facemasks, gloves, faceshield.
//3. Background from China.

import Foundation
import SpriteKit

var cameraNode: SKCameraNode = SKCameraNode()

struct levelData
{
    static var isMusicPlaying: Bool = true
    static var maxLevel: Int = 5
    static var reachedLevel: Int = 1 //P
    static var currentLevel: Int = 1 //P
    static var levelSelected: Int = -1
    static var handSanitizerCount: Int = 0 //P
    static var hasLocks: [Bool] = [false, true, true, true, true] //P
    static var didLoadFromHome: Bool = false
    static var hasMastered: Bool = false //P
    static var pressedReplay: Bool = false
    static var pressedNext: Bool = false
}

class HomeScene: SKScene
{
    var tutorialPopup: SKShapeNode = SKShapeNode()
    var tutorialText: SKLabelNode = SKLabelNode()
    var miniPeel: SKSpriteNode = SKSpriteNode()
    var swipeUpIcon: SKSpriteNode = SKSpriteNode()
    var swipeUpText: SKLabelNode = SKLabelNode()
    var miniBat: SKSpriteNode = SKSpriteNode()
    var swipeDownIcon: SKSpriteNode = SKSpriteNode()
    var swipeDownText: SKLabelNode = SKLabelNode()
    var miniSoap: SKSpriteNode = SKSpriteNode()
    var soapText: SKLabelNode = SKLabelNode()
    var miniZombie: SKSpriteNode = SKSpriteNode()
    var zombieText: SKLabelNode = SKLabelNode()
    var miniMask: SKSpriteNode = SKSpriteNode()
    var maskText: SKLabelNode = SKLabelNode()
    var swipeUp: SKSpriteNode = SKSpriteNode()
    var swipeDown: SKSpriteNode = SKSpriteNode()
    var closeIcon: SKSpriteNode = SKSpriteNode()
    var closeShape: SKShapeNode = SKShapeNode()
    
    var frozenBackground: SKSpriteNode = SKSpriteNode()
    var frozenPlatform: SKSpriteNode = SKSpriteNode()
    var idleCharacter: SKSpriteNode = SKSpriteNode()
    var greenSplat: SKSpriteNode = SKSpriteNode()
    var mainTitleScreen: SKLabelNode = SKLabelNode()
    var iconHolder: SKShapeNode = SKShapeNode()
    var rateButton: SKSpriteNode = SKSpriteNode()
    var rateButtonShape: SKShapeNode = SKShapeNode()
    var tutorialButton: SKSpriteNode = SKSpriteNode()
    var tutorialButtonShape: SKShapeNode = SKShapeNode()
    var soundButton: SKSpriteNode = SKSpriteNode()
    var soundButtonShape: SKShapeNode = SKShapeNode()
    var menuButton: SKSpriteNode = SKSpriteNode()
    var menuButtonShape: SKShapeNode = SKShapeNode()
    var clickToStart: SKLabelNode = SKLabelNode()
    
    var handSanitizerScore: Int = 0
    var scoreLabel: SKLabelNode = SKLabelNode()
    var miniHandSanitizer: SKSpriteNode = SKSpriteNode()
    var scoreLabelShape: SKShapeNode = SKShapeNode()
        
    override func didMove(to view: SKView) {
        
        print("yo")
        
        pullSavedData()
        
        if(cameraNode.children.count > 0)
        {
            cameraNode.removeAllChildren()
        }
        
        initTutorial()
        initTitleScreen()
        addBackgFreezeFrame()
        addPlatformFreezeFrame()
        showBackground()
        addIdleCharacter()
        drawSoundButton()
    }
    
    func wipeData() {
        
        GameScene.defaults.removeObject(forKey: "reachedlevel")
        GameScene.defaults.removeObject(forKey: "handsanitizercount")
        GameScene.defaults.removeObject(forKey: "currentlevel")
        GameScene.defaults.removeObject(forKey: "haslocks")
        GameScene.defaults.removeObject(forKey: "hasmastered")
    }
    
    func pullSavedData() {
        
        let reached = GameScene.defaults.integer(forKey: "reachedlevel")
        let count = GameScene.defaults.integer(forKey: "handsanitizercount")
        let currentLevel = GameScene.defaults.integer(forKey: "currentlevel")
        let locks = GameScene.defaults.array(forKey: "haslocks") as? [Bool]
        let mastered = GameScene.defaults.bool(forKey: "hasmastered")
        
        if(reached > 0)
        {
            levelData.reachedLevel = reached
        }
        if(count > 0)
        {
            levelData.handSanitizerCount = count
        }
        if(currentLevel > 0)
        {
            levelData.currentLevel = currentLevel
        }
        if(locks != nil)
        {
            levelData.hasLocks = locks ?? [false, true, true, true, true]
        }
        levelData.hasMastered = mastered
        
        //print(levelData.reachedLevel)
        //print(levelData.handSanitizerCount)
        //print(levelData.currentLevel)
        //print(levelData.hasLocks)
        //print(levelData.hasMastered)
    }
    
    func showBackground() {
        
        self.addChild(cameraNode)
    }
    
    func initText() {
        
        swipeUpText = SKLabelNode(fontNamed: "DKHand-Regular")
        swipeUpText.fontColor = .white
        swipeUpText.fontSize = 30
        swipeUpText.text = "Swipe up to jump and dodge peels"
        swipeUpText.zPosition = 5
        tutorialPopup.addChild(swipeUpText)
        swipeUpText.position = CGPoint(x: -10, y: tutorialPopup.frame.size.height / 4.5)

        
        swipeDownText = SKLabelNode(fontNamed: "DKHand-Regular")
        swipeDownText.fontColor = .white
        swipeDownText.fontSize = 30
        swipeDownText.text = "Swipe down to slide and dodge bats"
        swipeDownText.zPosition = 5
        tutorialPopup.addChild(swipeDownText)
        swipeDownText.position = CGPoint(x: -5, y: tutorialPopup.frame.size.height / 9.5)
        
        zombieText = SKLabelNode(fontNamed: "DKHand-Regular")
        zombieText.fontColor = .white
        zombieText.fontSize = 30
        zombieText.text = "Swipe up/down to dodge the zombie's sneeze"
        zombieText.zPosition = 5
        tutorialPopup.addChild(zombieText)
        zombieText.position = CGPoint(x: -46, y: -tutorialPopup.frame.size.height / 12)
        
        soapText = SKLabelNode(fontNamed: "DKHand-Regular")
        soapText.fontColor = .white
        soapText.fontSize = 30
        soapText.text = "Collect bottles to trade in for future rewards"
        soapText.zPosition = 5
        tutorialPopup.addChild(soapText)
        soapText.position = CGPoint(x: -42, y: -tutorialPopup.frame.size.height / 4)
        
        
        maskText = SKLabelNode(fontNamed: "DKHand-Regular")
        maskText.fontColor = .white
        maskText.fontSize = 30
        maskText.text = "Collect masks in-game for an extra life"
        maskText.zPosition = 5
        tutorialPopup.addChild(maskText)
        maskText.position = CGPoint(x: -70, y: -tutorialPopup.frame.size.height / 2.5)

    }
    
    func initMiniObjects() {
        
        miniZombie = SKSpriteNode(imageNamed: "blondezombie-5.png")
        miniZombie.size = CGSize(width: miniZombie.size.width / 2.5, height: miniZombie.size.height / 2.5)
        miniZombie.position = CGPoint(x: tutorialPopup.frame.size.width / 2.75, y: -15)

        miniZombie.zPosition = 5
        tutorialPopup.addChild(miniZombie)
        
        miniPeel = SKSpriteNode(imageNamed: "banana-peel.png")
        miniPeel.size = CGSize(width: miniPeel.size.width / 10, height: miniPeel.size.height / 10)
        miniPeel.position = CGPoint(x: tutorialPopup.frame.size.width / 2.75, y: tutorialPopup.frame.size.height / 4)
        miniPeel.zPosition = 5
        tutorialPopup.addChild(miniPeel)
                
        miniBat = SKSpriteNode(imageNamed: "batframe-1.png")
        miniBat.size = CGSize(width: miniBat.size.width / 4, height: miniBat.size.height / 4)
        miniBat.position = CGPoint(x: tutorialPopup.frame.size.width / 2.75, y: tutorialPopup.frame.size.height / 8)
        miniBat.zPosition = 5
        tutorialPopup.addChild(miniBat)
        
        miniSoap = SKSpriteNode(imageNamed: "hand-sanitizer.png")
        miniSoap.size = CGSize(width: miniSoap.size.width / 12, height: miniSoap.size.height / 12)
        miniSoap.position = CGPoint(x: tutorialPopup.frame.size.width / 2.75, y: -tutorialPopup.frame.size.height / 4.25)
        miniSoap.zPosition = 5
        tutorialPopup.addChild(miniSoap)
        
        miniMask = SKSpriteNode(imageNamed: "mask.png")
        miniMask.xScale = -1
        miniMask.size = CGSize(width: miniMask.size.width / 10, height: miniMask.size.height / 10)
        miniMask.position = CGPoint(x: tutorialPopup.frame.size.width / 3.25, y: -tutorialPopup.frame.size.height / 2.5)
        miniMask.zPosition = 5
        tutorialPopup.addChild(miniMask)
        
        swipeUp = SKSpriteNode(imageNamed: "swipe-up")
        swipeUp.size = CGSize(width: swipeUp.size.width / 10, height: swipeUp.size.height / 10)
        swipeUp.position = CGPoint(x: -tutorialPopup.frame.size.width / 2.5, y: tutorialPopup.frame.size.height / 4)
        swipeUp.zPosition = 5
        tutorialPopup.addChild(swipeUp)
        
        swipeDown = SKSpriteNode(imageNamed: "swipe-below")
        swipeDown.size = CGSize(width: swipeDown.size.width / 10, height: swipeDown.size.height / 10)
        swipeDown.position = CGPoint(x: -tutorialPopup.frame.size.width / 2.5, y: tutorialPopup.frame.size.height / 8)
        swipeDown.zPosition = 5
        tutorialPopup.addChild(swipeDown)
        
        closeIcon = SKSpriteNode(imageNamed: "close-icon.png")
        closeIcon.name = "closebutton"
        closeIcon.isUserInteractionEnabled = false
        closeIcon.size = CGSize(width: closeIcon.size.width / 40, height: closeIcon.size.height / 40)
        closeIcon.zPosition = 5
        closeIcon.position = CGPoint(x: tutorialPopup.frame.size.width / 2.25, y: tutorialPopup.frame.size.height / 2.3)
        tutorialPopup.addChild(closeIcon)
        
    }
    
    func initTutorial() {
        
        tutorialPopup = SKShapeNode(rect: CGRect(x: -self.frame.width / 3, y: -self.frame.height / 6, width: (2 * self.frame.width) / 3, height: (self.frame.height) / 3))
        tutorialPopup.fillColor = .orange
        tutorialPopup.strokeColor = .white
        tutorialPopup.lineWidth = 5
        tutorialPopup.zPosition = 4
        
        tutorialText = SKLabelNode(fontNamed: "DKHand-Regular")
        tutorialText.fontColor = .white
        tutorialText.fontSize = 40
        tutorialText.text = "Help Bobby Escape The Sick World"
        tutorialPopup.addChild(tutorialText)
        tutorialText.position.y = tutorialPopup.frame.size.height / 3
        
        initMiniObjects()
        initText()
        tutorialPopup.alpha = 0.0
        self.addChild(tutorialPopup)
    }
    
    func showTutorial() {
       
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        let fadeRepeater = SKAction.repeat(fadeIn, count: 1)
        
        tutorialPopup.run(fadeRepeater)
    }
    
    func hideTutorial() {
        
        let fadeOut = SKAction.fadeOut(withDuration: 0)
        
        let fadeRepeater = SKAction.repeat(fadeOut, count: 1)
        
        tutorialPopup.run(fadeRepeater)
    }
    
    func showScore() {
           
       scoreLabel = SKLabelNode(fontNamed: "KeyVirtueRegular")
       scoreLabel.text = String(handSanitizerScore)
       scoreLabel.fontColor = .white
       scoreLabel.fontSize = 84
       
       miniHandSanitizer = SKSpriteNode(imageNamed: "hand-sanitizer.png")
       miniHandSanitizer.size = CGSize(width: miniHandSanitizer.size.width / 8, height: miniHandSanitizer.size.height / 8)
       miniHandSanitizer.position = CGPoint(x: -150, y: -50)
       scoreLabel.position = CGPoint(x: -75, y: -75)
       
       scoreLabelShape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: -200, height: -100), cornerRadius: 100)
       
       scoreLabelShape.addChild(scoreLabel)
       scoreLabelShape.addChild(miniHandSanitizer)
   
       
       if(UIDevice.current.userInterfaceIdiom == .pad)
       {
           scoreLabelShape.position.x = self.frame.width / 2
           scoreLabelShape.position.y = self.frame.height / 2.5
       }
       if(UIDevice.current.userInterfaceIdiom == .phone)
       {
           scoreLabelShape.position.x = self.frame.width / 2
           scoreLabelShape.position.y = self.frame.height / 2
       }

       //scoreLabelShape.fillColor = .
       scoreLabelShape.strokeColor = .green
       scoreLabelShape.lineWidth = 5
       scoreLabelShape.isAntialiased = true
       
       self.addChild(scoreLabelShape)
  }
    
    func addBackgFreezeFrame()
    {
        if(cameraNode.contains(frozenBackground))
        {
            return
        }
        
        let backgTexture = SKTexture(imageNamed: "seamless-background.png")
            
        let backgAnimation = SKAction.move(by: CGVector(dx: -backgTexture.size().width, dy: 0), duration: 3)
        
        let backgShift = SKAction.move(by: CGVector(dx: backgTexture.size().width, dy: 0), duration: 0)
        let bgAnimation = SKAction.sequence([backgAnimation, backgShift])
        let infiniteBackg = SKAction.repeatForever(bgAnimation)
                
        var i: CGFloat = 0

        while i < 2 {
            
            frozenBackground = SKSpriteNode(texture: backgTexture)
            frozenBackground.name = "background" + String(format: "%.0f", Double(i))
            frozenBackground.position = CGPoint(x: backgTexture.size().width * i, y: self.frame.midY)
            frozenBackground.size.height = self.frame.height
            frozenBackground.run(infiniteBackg, withKey: "background")

            cameraNode.addChild(frozenBackground)

            i += 1

            // Set background first
            frozenBackground.zPosition = -2
            frozenBackground.speed = 0
        }
    }
    
    func addPlatformFreezeFrame() {
        
        if(cameraNode.contains(frozenPlatform))
        {
            return
        }
        
        frozenPlatform = SKSpriteNode(imageNamed: "world1.png")
        let pfTexture = SKTexture(imageNamed: "world1.png")
        
        let movePfAnimation = SKAction.move(by: CGVector(dx: -pfTexture.size().width, dy: 0), duration: 3)
        let shiftPfAnimation = SKAction.move(by: CGVector(dx: pfTexture.size().width, dy: 0), duration: 0)
        
        let pfAnimation = SKAction.sequence([movePfAnimation, shiftPfAnimation])
        let movePfForever = SKAction.repeatForever(pfAnimation)
                
        var i: CGFloat = 0
        
        while i < 2 {
                
            frozenPlatform = SKSpriteNode(imageNamed: "world1.png")
            frozenPlatform.size.width = self.frame.width * 2
            frozenPlatform.position = CGPoint(x: i * pfTexture.size().width, y: -(self.frame.height / 2.5))
            frozenPlatform.name = "platform" + String(format: "%.0f", Double(i))
            frozenPlatform.size.height = self.frame.height / 3.5
    
            frozenPlatform.run(movePfForever, withKey: "platform")
            
            cameraNode.addChild(frozenPlatform)
            
            i += 1

            // Set platform first
            frozenPlatform.zPosition = 0;
            frozenPlatform.speed = 0
        }
    }
    
    func addIdleCharacter() -> Void {
        
        if(cameraNode.contains(idleCharacter))
        {
            return
        }
        //idleCharacter.removeAllActions()
        idleCharacter = SKSpriteNode(imageNamed: "(b)obby-1.png")
        
        idleCharacter.position = CGPoint(x: self.frame.minX / 2.35, y: self.frame.minY / 1.71)
        idleCharacter.name = "character"
        idleCharacter.size = CGSize(width: idleCharacter.size.width / 2, height: idleCharacter.size.height / 2)
        idleCharacter.color = .black
        idleCharacter.colorBlendFactor = 0.1
        idleCharacter.zPosition = 2;
        
        let idleFrames: [SKTexture] = [SKTexture(imageNamed: "idle-1"), SKTexture(imageNamed: "idle-2")/*, SKTexture(imageNamed: "idle-3"),*/]//, SKTexture(imageNamed: "idle-4")]
        
        let idleAnim = SKAction.animate(with: idleFrames, timePerFrame: 0.25)
        
        let idleForever = SKAction.repeatForever(idleAnim)
        
        cameraNode.addChild(idleCharacter)
        idleCharacter.run(idleForever)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if((node?.name == "menuicon") || (node?.name == "menubutton"))
            {
                cleanUp()
                let menuScene = MenuScene(fileNamed: "MenuScene")
                levelData.didLoadFromHome = false
                menuScene?.scaleMode = .aspectFill
                self.view?.presentScene(menuScene)
            }
            else if((node?.name == "soundbutton") || (node?.name == "soundshape"))
            {
                levelData.isMusicPlaying = !levelData.isMusicPlaying
                
                if(levelData.isMusicPlaying)
                {
                    soundButton.texture = SKTexture(imageNamed: "volume-off")
                    GameViewController.audioPlayer?.currentTime = 0
                    GameViewController.audioPlayer?.play()
                }
                else
                {
                    soundButton.texture = SKTexture(imageNamed: "volume-on")
                    GameViewController.audioPlayer?.pause()
                }
            }
            else if((node?.name == "tutorialbutton") || (node?.name == "tutorialshape"))
            {
                showTutorial()
            }
                
            else if(node?.name == "closebutton")
            {
                hideTutorial()
            }
            
            else
            {
                
                
                cleanUp()
                levelData.didLoadFromHome = true
                
                if(levelData.currentLevel == 6)
                {
                    levelData.hasMastered = true
                    let menuScene = MenuScene(fileNamed: "MenuScene")
                    levelData.didLoadFromHome = false
                    menuScene?.scaleMode = .aspectFill
                    self.view?.presentScene(menuScene)
                }
                else
                {
                    let gameScene = GameScene(fileNamed: "GameScene")
                    gameScene?.scaleMode = .aspectFill
                    self.view?.presentScene(gameScene!, transition: SKTransition.crossFade(withDuration: 0.5))
                }
            }
        }
    }
    
    func initTitleScreen() {
        
        drawGreenSplat()
        drawMainText()
        drawIconRect()
        drawLikeButton()
        drawTutorialButton()
        drawMenuButton()
        drawClickToStart()
    }
    
    func drawGreenSplat() {
        
        greenSplat = SKSpriteNode(imageNamed: "green-splat.png")
        greenSplat.zPosition = 3
        if UIDevice.current.userInterfaceIdiom == .pad {
          
        greenSplat.size = CGSize(width: (self.frame.width - greenSplat.size.width) * 3.75, height: (self.frame.width - greenSplat.size.height) * 3.75)
        greenSplat.position = CGPoint(x: self.frame.midX - 20, y: self.frame.midY + 320)
        }
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
           greenSplat.size = CGSize(width: (self.frame.width - greenSplat.size.width) * 4, height: (self.frame.width - greenSplat.size.height) * 4)
            greenSplat.position = CGPoint(x: self.frame.midX - 20, y: self.frame.midY + 400)
        }
        self.addChild(greenSplat)
    }
    
    func drawMainText() {
        
        mainTitleScreen = SKLabelNode(fontNamed: "MaassslicerItalic")
        
        mainTitleScreen.position = CGPoint(x: self.frame.midX, y: self.frame.maxY / 1.85)
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            mainTitleScreen.position.y = self.frame.maxY / 2.3
        }
        
        mainTitleScreen.fontColor = .black
        mainTitleScreen.fontSize = 100
        mainTitleScreen.numberOfLines = 1
        mainTitleScreen.text = "Corona Run"
        mainTitleScreen.zPosition = 4
        
        self.addChild(mainTitleScreen)
    }
    
    func drawIconRect() {
        
        iconHolder = SKShapeNode(rect: CGRect(x: -self.frame.width, y: self.frame.midY, width: (2 * self.frame.width), height: self.frame.height / 13))
        
        iconHolder.fillColor = .clear
        iconHolder.lineWidth = 5
        iconHolder.isAntialiased = true
        iconHolder.strokeColor = .black
        
        self.addChild(iconHolder)
    }
    
    func drawLikeButton() {
        
        rateButton = SKSpriteNode(imageNamed: "like-icon.png")
        rateButton.size = CGSize(width: rateButton.size.width / 19, height: rateButton.size.height / 19)
        rateButton.position = CGPoint(x: 0, y: 0)
        
        rateButtonShape = SKShapeNode(circleOfRadius: 55)
        rateButtonShape.fillColor = .white
        rateButtonShape.isAntialiased = true
        rateButtonShape.isUserInteractionEnabled = false
        rateButtonShape.lineWidth = 5
        rateButtonShape.strokeColor = .black
        rateButtonShape.addChild(rateButton)
        
        iconHolder.addChild(rateButtonShape)
        
        rateButtonShape.position = CGPoint(x: -self.size.width / 3, y: 50)
    }
    
    func drawTutorialButton() {
        
        tutorialButton = SKSpriteNode(imageNamed: "question-mark.png")
        tutorialButton.name = "tutorialbutton"
        tutorialButton.size = CGSize(width: tutorialButton.size.width / 7 , height: tutorialButton.size.height / 7)
        tutorialButton.isUserInteractionEnabled = false
        tutorialButton.position = CGPoint(x: 0, y: 0)
        
        tutorialButtonShape = SKShapeNode(circleOfRadius: 55)
        tutorialButtonShape.isUserInteractionEnabled = false
        tutorialButtonShape.name = "tutorialshape"
        tutorialButtonShape.fillColor = .white
        tutorialButtonShape.isAntialiased = true
        tutorialButtonShape.isUserInteractionEnabled = false
        tutorialButtonShape.lineWidth = 5
        tutorialButtonShape.strokeColor = .black
        tutorialButtonShape.addChild(tutorialButton)
        
        iconHolder.addChild(tutorialButtonShape)
        
        tutorialButtonShape.position = CGPoint(x: -self.size.width / 9, y: 50)
    }
    
    func drawSoundButton() {
        
        soundButton = SKSpriteNode(imageNamed: "volume-off.png")
        soundButton.name = "soundbutton"
        soundButton.size = CGSize(width: soundButton.size.width / 6 , height: soundButton.size.height / 6)
        soundButton.isUserInteractionEnabled = false
        soundButton.position = CGPoint(x: 0, y: 0)
        
        soundButtonShape = SKShapeNode(circleOfRadius: 55)
        soundButton.name = "soundshape"
        soundButtonShape.fillColor = .white
        soundButtonShape.isAntialiased = true
        soundButtonShape.isUserInteractionEnabled = false
        soundButtonShape.lineWidth = 5
        soundButtonShape.strokeColor = .black
        soundButtonShape.addChild(soundButton)
        
        iconHolder.addChild(soundButtonShape)
        
        soundButtonShape.position = CGPoint(x: self.size.width / 3, y: 50)
    }
    
    func drawMenuButton() {
        
        menuButton = SKSpriteNode(imageNamed: "menu-icon.png")
        menuButton.size = CGSize(width: menuButton.size.width / 5 , height: menuButton.size.height / 5)
        menuButton.name = "menuicon"
        menuButton.isUserInteractionEnabled = false
        
        menuButtonShape = SKShapeNode(circleOfRadius: 55)
        menuButtonShape.fillColor = .white
        menuButtonShape.name = "menubutton"
        menuButtonShape.isAntialiased = true
        menuButtonShape.isUserInteractionEnabled = false
        menuButtonShape.lineWidth = 5
        menuButtonShape.strokeColor = .black
        menuButtonShape.addChild(menuButton)
        menuButton.position = CGPoint(x: 15, y: 0)
        
        iconHolder.addChild(menuButtonShape)
        
        menuButtonShape.position = CGPoint(x: self.size.width / 9, y: 50)
    }
    
    func drawClickToStart() {
        
        clickToStart = SKLabelNode(fontNamed: "Balibold-Regular")
        clickToStart.fontColor = .white
        clickToStart.fontSize = 30
        clickToStart.text = "Click to start"
        clickToStart.position = CGPoint(x: 0, y: self.frame.minY / 3)
        clickToStart.alpha = 1
        
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
       
        let fadeSequence = SKAction.sequence([fadeIn, fadeOut])
        
        let fadeForever = SKAction.repeat(fadeSequence, count: 1)
        
        self.addChild(clickToStart)
        clickToStart.run(fadeForever)
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

    func getBackground() -> SKSpriteNode {
        
        return frozenBackground
    }
    
    func getPlatform() -> SKSpriteNode {
        
        return frozenPlatform
    }
}
