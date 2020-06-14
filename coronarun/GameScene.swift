//
//  GameScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/13/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//
//0. Implement the app delegate methods (ex. Hit home button after dying)
//2. Randomize objects
//3. Implement time-based closing animation
//4  Score board
//5. Make sure it works on all devices
//6. Make sure orientation is dynamic
//7. Images need to be put in separate directories with a naming scheme.


import SpriteKit
import GameplayKit

struct ColliderType
{
    static let none: UInt32 = 0x1 << 0
    static let character: UInt32 = 0x1 << 1
    static let banana: UInt32 = 0x1 << 2
    static let germs: UInt32 = 0x1 << 3
    static let girl: UInt32 = 0x1 << 4
    static let soap: UInt32 = 0x1 << 5
    static let portal: UInt32 = 0x1 << 6
}

struct game {
    
    static var IsOver : Bool = false
    static var contactDetected: Bool = false
    static var i: Int = 0
    static var charInitalPos: CGPoint = CGPoint(x: 0, y: 0)
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let playerSpeedPerFrame = 0.25
    let playerJumpPerFrame = 1.0
    let maxTimeMoving: CGFloat = 2
    let bgAnimatedInSecs: TimeInterval = 3
    let MIN_THRESHOLD_MS: Double = 1000
    
    var portal: SKSpriteNode = SKSpriteNode()
    var glitter: SKEmitterNode = SKEmitterNode()
    var soap: SKSpriteNode = SKSpriteNode()
    var characterSprite: SKSpriteNode = SKSpriteNode()
    var batSprite: SKSpriteNode = SKSpriteNode()
    var batSprite2: SKSpriteNode = SKSpriteNode()
    var batSprite3: SKSpriteNode = SKSpriteNode()
    var tempIdleChar: SKSpriteNode = SKSpriteNode()
    var background: SKSpriteNode = SKSpriteNode()
    var platform: SKSpriteNode = SKSpriteNode()
    var blueGermCloud: SKSpriteNode = SKSpriteNode()
    var greenGermCloud: SKSpriteNode = SKSpriteNode()
    var bananaPeel: SKSpriteNode = SKSpriteNode()
    var littleGirl: SKSpriteNode = SKSpriteNode()
    var replayButton: SKSpriteNode = SKSpriteNode()
    var replayShape: SKShapeNode = SKShapeNode()
    var nextLevelButton: SKSpriteNode = SKSpriteNode()
    var nextLevelShape: SKShapeNode = SKShapeNode()
    var homeButton: SKSpriteNode = SKSpriteNode()
    var homeButtonShape: SKShapeNode = SKShapeNode()
    var menuButton: SKSpriteNode = SKSpriteNode()
    var menuButtonShape: SKShapeNode = SKShapeNode()
    var score: Int = 0
    var temp: Int = 0
    var lives: Int = 1
    var isLevelPassed: Bool = false
    var timer: Timer = Timer()
    var runAction: SKAction = SKAction()
    var lastTime: Double = 0
    var gameOverDisplay: SKShapeNode = SKShapeNode()
    var levelAlert: SKLabelNode = SKLabelNode()
    var levelStatusAlert: SKLabelNode = SKLabelNode()
    var scoreLabel: SKSpriteNode = SKSpriteNode()
    
    override func didMove(to view: SKView) -> Void {

        GameViewController.gameScene = self
        self.physicsWorld.contactDelegate = self
        initializeGame()
        
        //to-do: Make these obstacle objects random
}
    func initializeGame() -> Void {
        
        resumeNodes()
        drawCharacter()
        initObjectPhysics()
        addSoap()
        //drawBats()
        
        
        //timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(drawRandom), userInfo: nil, repeats: true)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(jumpUp))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(slideDown))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
    }
    
    func resumeNodes() {
        
        backGBlur.shouldEnableEffects = false
        for child in cameraNode.children {
            
            if(child.isEqual(to: backGBlur))
            {
                for backG in child.children {
                    
                    backG.speed = 1.5
                }
            }
                
            if((child.name == "platform0") || (child.name == "platform1") || (child.name == "platform2"))
            {
                child.speed = 1.5
            }
            
            else if(child.name == "character")
            {
                game.charInitalPos = child.position
                child.isHidden = true
            }
        }
        self.addChild(cameraNode)
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
        
        characterSprite.isHidden = true
        
        let portalMinimize = SKAction.resize(toWidth: 0, height: 0, duration: bgAnimatedInSecs / 10)
        
        

        let portalMinimizeRepeater = SKAction.repeat(portalMinimize, count: 1)
        
        
        portal.run(portalMinimizeRepeater)
        endGame()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        
        game.contactDetected = true
        
        print("contact...")
        
        let nodeA = contact.bodyA
        let nodeB = contact.bodyB
        
        if(((nodeA.node?.name == "character") && (nodeB.node?.name == "portal")) || ((nodeA.node?.name == "portal") && (nodeB.node?.name == "character")))
        {
            characterSprite.physicsBody?.isDynamic = false
            portal.physicsBody?.isDynamic = false
            minimizeChar()
        }
        
        if(((nodeA.node?.name == "character") && (nodeB.node?.name == "soap")) || ((nodeA.node?.name == "soap") && (nodeB.node?.name == "character")))
        {
            score += 1
            soap.physicsBody?.isDynamic = false
            soap.isHidden = true
            game.contactDetected = false
        }
        
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "banana")) || ((nodeA.node?.name == "banana") && (nodeB.node?.name == "character")))
        {
            self.view?.gestureRecognizers?.removeAll()
            peelDieAnimation()
        }
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "germ")) || ((nodeA.node?.name == "germ") && (nodeB.node?.name == "character")))
        {
            self.view?.gestureRecognizers?.removeAll()
            germDieAnimation()
        }
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "girl")) || ((nodeA.node?.name == "girl") && (nodeB.node?.name == "character")))
        {
            self.view?.gestureRecognizers?.removeAll()
            girlDieAnimation()
        }
    }

    @objc func timerAction(){
       print("timer fired!")
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
    
    func initReplayButton() -> Void {
        
        replayButton = SKSpriteNode(imageNamed: "replay-button.png")
        replayButton.name = "replaybutton"
        //replayButton.color = .white
        replayButton.zPosition = 4
        //replayButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        replayShape = SKShapeNode(circleOfRadius: replayButton.size.width / 2)
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
        //nextLevelButton.color = .white
        nextLevelButton.zPosition = 4

        //nextLevelButton.position = CGPoint(x: self.frame.midX + 230, y: self.frame.midY)
        
        nextLevelShape = SKShapeNode(circleOfRadius: replayButton.size.width / 2)
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

        homeButtonShape = SKShapeNode(circleOfRadius: replayButton.size.width / 2)
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
        
        gameOverDisplay = SKShapeNode(rect: CGRect(x: -self.frame.width, y: self.frame.midY - 20, width: self.frame.width * 2, height: 300))
        gameOverDisplay.fillColor = .black
        gameOverDisplay.alpha = 0.5
                
        levelAlert = SKLabelNode(fontNamed: "CarbonBl-Regular")
        levelAlert.fontColor = .white
        levelAlert.fontSize = 72
        levelAlert.position = CGPoint(x: 0, y: 200)
        levelAlert.text = "Level Beta:"
        
        levelStatusAlert = SKLabelNode(fontNamed: "CarbonBl-Regular")
        levelStatusAlert.fontSize = 72
        levelStatusAlert.position = CGPoint(x: 0, y: 125)
        
        if(isLevelPassed)
        {
            self.initNextLevelButton()
            levelStatusAlert.fontColor = .green
            levelStatusAlert.text = "PASSED"
        }
        else
        {
            self.initMenuButton()
            levelStatusAlert.fontColor = .red
            levelStatusAlert.text = "FAILED"
        }
        
        self.initReplayButton()
        self.initHomeButton()
        
        self.addChild(gameOverDisplay)
        self.addChild(levelAlert)
        self.addChild(levelStatusAlert)
    }
    
    //This function will be scrapped.
    /*
    func closingScene() -> Void{
                
        house = SKSpriteNode(imageNamed: "house.png")
        house.size = CGSize(width: house.size.width / 3, height: house.size.height / 3)
        house.position = CGPoint(x: self.frame.width * 2, y: self.frame.minY / 1.9)
        
        self.addChild(house)
        
        let standingFrames:[SKTexture] = [SKTexture(imageNamed: "bobby-1.png"), SKTexture(imageNamed: "bobby-2.png"), SKTexture(imageNamed: "bobby-3.png"), SKTexture(imageNamed: "bobby-4.png")]
        
        let standingAnim = SKAction.animate(with: standingFrames, timePerFrame: 0.25)
        let moveToHouse = SKAction.move(to: CGPoint(x: self.frame.maxX / 1.5, y: self.frame.minY / 1.9), duration: 1)
        
        let charMoveToHouse = SKAction.move(to: CGPoint(x: self.frame.maxX / 4, y: self.frame.minY / 1.70), duration: 1)
        
        let repeatingStanding = SKAction.repeatForever(standingAnim)
        let houseShift = SKAction.repeat(moveToHouse, count: 1)
        let charShift = SKAction.repeat(charMoveToHouse, count: 1)
        
        house.run(houseShift, withKey: "houseshift")
        
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            //self.background.isPaused = true
            //self.platform.isPaused = true
            self.house.removeAction(forKey: "houseshift")
            self.characterSprite.run(charShift, withKey: "movetohouse")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
                self.characterSprite.removeAllActions()
                self.characterSprite.texture = SKTexture(imageNamed: "bobby-1.png")
                self.characterSprite.run(repeatingStanding)
                DispatchQueue.main.asyncAfter(deadline: .now() + (seconds * 2))
                {
                    self.endGame()
                }
            }
        }
    }
 */

    func pauseRunning() -> Void{
        
        let runningAction: SKAction? = characterSprite.action(forKey: "running")
        
        if let tmp = runningAction{
            
            characterSprite.removeAction(forKey: "running")
            self.runAction = runningAction!
        }
        
    }
    
    func resumeRunning() -> Void{
        
        characterSprite.run(runAction, withKey: "running")
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
        
        print("jumpUp")
        pauseRunning()
        
        if(!game.contactDetected)
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
        print("jumpDown")
        pauseRunning()
        
        if(!game.contactDetected)
        {
            duckCharacter()
        }
    }
    
    func drawBackground() -> Void{
        
        self.removeAllChildren()
        
        let backgTexture = SKTexture(imageNamed: "seamless-background.png")
            
        let backgAnimation = SKAction.move(by: CGVector(dx: -backgTexture.size().width, dy: 0), duration: bgAnimatedInSecs)
        
        let backgShift = SKAction.move(by: CGVector(dx: backgTexture.size().width, dy: 0), duration: 0)
        let bgAnimation = SKAction.sequence([backgAnimation, backgShift])
        let infiniteBackg = SKAction.repeatForever(bgAnimation)

        var i: CGFloat = 0

        while i < maxTimeMoving {
            
            background = SKSpriteNode(texture: backgTexture)
            background.name = "background"
            background.position = CGPoint(x: backgTexture.size().width * i, y: self.frame.midY)
            background.size.height = CGFloat((self.scene?.size.height)!)
            background.run(infiniteBackg, withKey: "background")

            self.addChild(background)

            i += 1

            // Set background first
            background.zPosition = -2
        }
    }
    
    func drawPlatform() -> Void{
        
        let pfTexture = SKTexture(imageNamed: "grounds.png")
        
        let movePfAnimation = SKAction.move(by: CGVector(dx: -pfTexture.size().width, dy: 0), duration: bgAnimatedInSecs)
        let shiftPfAnimation = SKAction.move(by: CGVector(dx: pfTexture.size().width, dy: 0), duration: 0)
        
        let pfAnimation = SKAction.sequence([movePfAnimation, shiftPfAnimation])
        let movePfForever = SKAction.repeatForever(pfAnimation);
        
        var i: CGFloat = 0
        
        
        
        while i < maxTimeMoving{
            
            platform = SKSpriteNode(imageNamed: "grounds.png")
            
            platform.position = CGPoint(x: i * pfTexture.size().width, y: -(scene?.size.height)! / 2.73)
            platform.name = "platform"
            platform.size.height = 400;
    
            platform.run(movePfForever, withKey: "platform")
            
            self.addChild(platform)
            
            i += 1

            // Set platform first
            platform.zPosition = -1;
        }
    }
    
    func drawCharacter() -> Void{
        
        //let runAnimations:[SKTexture] = [SKTexture(imageNamed: "row-1-col-1.png"), SKTexture(imageNamed: "row-1-col-2.png"), SKTexture(imageNamed: "row-1-col-3.png"), SKTexture(imageNamed: "row-2-col-1.png"), SKTexture(imageNamed: "row-2-col-2.png"), SKTexture(imageNamed: "row-2-col-3.png")]
        
        //let lastFrame = SKTexture(imageNamed: "new11-removebg-preview.png")
        //lastFrame.
        
        let runAnimations:[SKTexture] = [SKTexture(imageNamed: "bobby-6.png"), SKTexture(imageNamed: "bobby-7.png"), SKTexture(imageNamed: "bobby-8.png"), SKTexture(imageNamed: "bobby-9.png"), SKTexture(imageNamed: "bobby-10.png"), SKTexture(imageNamed: "bobby-11.png")]
        
        let mainAnimated = SKAction.animate(with: runAnimations, timePerFrame: 0.2)
        let mainRepeater = SKAction.repeatForever(mainAnimated)
        
        characterSprite = SKSpriteNode(imageNamed: "bobby-6.png")
        characterSprite.name = "character"
        characterSprite.position = CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70)
        characterSprite.size = CGSize(width: characterSprite.size.width / 2, height: characterSprite.size.height / 2)
        characterSprite.color = .black
        characterSprite.colorBlendFactor = 0.1
        characterSprite.zPosition = 2;
        
        
        //Physics Body
        characterSprite.physicsBody = SKPhysicsBody(circleOfRadius: characterSprite.size.width / 2.5)
        characterSprite.physicsBody?.affectedByGravity = false
        characterSprite.physicsBody?.categoryBitMask = ColliderType.character
        characterSprite.physicsBody?.collisionBitMask = ColliderType.banana | ColliderType.germs
        characterSprite.physicsBody?.contactTestBitMask = ColliderType.banana | ColliderType.germs
        characterSprite.physicsBody?.usesPreciseCollisionDetection = true
        characterSprite.physicsBody?.isDynamic = true
        
        
        self.addChild(characterSprite)
        characterSprite.run(mainRepeater, withKey: "running")
    }
    
    func charMoveToPortal() {
        
        self.view?.gestureRecognizers?.removeAll()
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
        
        portal = SKSpriteNode(imageNamed: "cool-portal.png")
        portal.position = CGPoint(x: self.frame.width, y: game.charInitalPos.y + 100)
        portal.size = CGSize(width: portal.size.width, height: portal.size.height)
        portal.name = "portal"
        
        //Physics Body

        portal.physicsBody = SKPhysicsBody(circleOfRadius: portal.size.width / 6)
        portal.physicsBody?.affectedByGravity = false
        portal.physicsBody?.categoryBitMask = ColliderType.portal
        portal.physicsBody?.collisionBitMask = ColliderType.character
        portal.physicsBody?.contactTestBitMask = ColliderType.character
        portal.physicsBody?.usesPreciseCollisionDetection = true
        portal.physicsBody?.isDynamic = true
        
        
        
        let portalSpin = SKAction.rotate(byAngle: (2 * CGFloat.pi), duration: bgAnimatedInSecs / 2)
        let portalShift = SKAction.moveTo(x: self.frame.width / 2.5, duration: bgAnimatedInSecs / 2)
        let portalRepeater = SKAction.repeat(portalShift, count: 1)
        let spinRepeater = SKAction.repeatForever(portalSpin)
        
        self.addChild(portal)
        portal.run(spinRepeater)
        portal.run(portalRepeater, completion: charMoveToPortal)
    }
    
    func addGlitterEffect() {
        
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
    
    func drawBats() {
        
        let batFrames: [SKTexture] = [SKTexture(imageNamed: "batframe-1"), SKTexture(imageNamed: "batframe-2"), SKTexture(imageNamed: "batframe-3"), SKTexture(imageNamed: "batframe-4")]
        
        batSprite = SKSpriteNode(imageNamed: "batframe-1.png")
        batSprite2 = SKSpriteNode(imageNamed: "batframe-1.png")
        batSprite3 = SKSpriteNode(imageNamed: "batframe-1.png")

        batSprite.position = CGPoint(x: self.frame.width, y: game.charInitalPos.y + 100)
        batSprite.size = CGSize(width: batSprite.size.width / 1.75, height: batSprite.size.height / 1.75)
        batSprite.xScale = -1
        batSprite.zPosition = 2
        
        batSprite2.position = CGPoint(x: self.frame.width, y: game.charInitalPos.y + 100)
        batSprite2.size = CGSize(width: batSprite2.size.width / 1.75, height: batSprite2.size.height / 1.75)
        batSprite2.xScale = -1
        batSprite2.zPosition = 2
        
        batSprite3.position = CGPoint(x: self.frame.width, y: game.charInitalPos.y + 100)
        batSprite3.size = CGSize(width: batSprite3.size.width / 1.75, height: batSprite3.size.height / 1.75)
        batSprite3.xScale = -1
        batSprite3.zPosition = 2
        
        let batAnim = SKAction.animate(with: batFrames, timePerFrame: 0.2)
        let batAnimRepeater = SKAction.repeatForever(batAnim)
        let batShift = SKAction.move(to: CGPoint(x: -self.frame.width * 2, y: batSprite.position.y), duration: bgAnimatedInSecs)
        
        self.addChild(batSprite)
        self.addChild(batSprite2)
        self.addChild(batSprite3)
        
        batSprite2.isHidden = true
        batSprite3.isHidden = true

        batSprite.run(batAnimRepeater)
        batSprite2.run(batAnimRepeater)
        batSprite3.run(batAnimRepeater)
        
        batSprite.run(batShift, completion: batReversion)
    }
    
    func batReversion() -> Void {
        
        batSprite.xScale = 1
        let batReversion = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: self.frame.midY + 100), duration: bgAnimatedInSecs)
        batSprite.run(batReversion, completion: drawBat2)
    }
    
    func bat2Reversion() -> Void {
        
        batSprite2.xScale = 1
        let batReversion = SKAction.move(to: CGPoint(x: characterSprite.position.x - 100, y: self.frame.midY + 200), duration: bgAnimatedInSecs)
        batSprite2.run(batReversion, completion: drawBat3)
    }
    
    func bat3Reversion() -> Void {
        
        batSprite3.xScale = 1
        let batReversion = SKAction.move(to: CGPoint(x: characterSprite.position.x + 100, y: self.frame.midY + 200), duration: bgAnimatedInSecs)
        batSprite3.run(batReversion)
    }
    
    
    func drawBat2() {
        
        batSprite2.isHidden = false
        
        let batShift = SKAction.move(to: CGPoint(x: -self.frame.width * 2, y: batSprite2.position.y), duration: bgAnimatedInSecs)

        batSprite2.run(batShift, completion: bat2Reversion)
    }
    
    func drawBat3() {
        
        batSprite3.isHidden = false
        
        let batShift = SKAction.move(to: CGPoint(x: -self.frame.width * 2, y: batSprite3.position.y), duration: bgAnimatedInSecs)

        batSprite3.run(batShift, completion: bat3Reversion)
    }
       
    
    func jumpCharacter() -> Void{
                
        if(game.contactDetected)
        {
            return
        }
        
        let upAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.midY), duration: 0.5)
        let upRepeater = SKAction.repeat(upAction, count: 1)
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-12.png")
        characterSprite.run(upRepeater, completion: jumpLanding)
    }
    
    func jumpLanding() {
        
        let downAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.5)
        let downRepeater = SKAction.repeat(downAction, count: 1)

        characterSprite.texture = SKTexture(imageNamed: "bobby-13.png")
        characterSprite.run(downRepeater, completion: resumeRunning)
    }
    
    func duckCharacter() -> Void {
        
       let duckFrames:[SKTexture] = [SKTexture(imageNamed: "bobby-5.png")]
                        
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
    
    func initObjectPhysics() -> Void{
        
        //blueGermCloud
        blueGermCloud = SKSpriteNode(imageNamed: "blue-germ-1")
        blueGermCloud.size = CGSize(width: 200, height: 200)
        blueGermCloud.position = CGPoint(x: self.frame.size.width, y: (self.frame.minY / 2.65))
        blueGermCloud.zPosition = 3
        blueGermCloud.name = "germ"
        
        blueGermCloud.physicsBody = SKPhysicsBody(circleOfRadius: blueGermCloud.size.width / 2.3)
        blueGermCloud.physicsBody?.affectedByGravity = false
        blueGermCloud.physicsBody?.categoryBitMask = ColliderType.germs
        blueGermCloud.physicsBody?.collisionBitMask = ColliderType.character
        blueGermCloud.physicsBody?.contactTestBitMask = ColliderType.character
        blueGermCloud.physicsBody?.isDynamic = false
        
        self.addChild(blueGermCloud)
        
        //greenGermCloud
        greenGermCloud = SKSpriteNode(imageNamed: "green-germ-1")
        greenGermCloud.size = CGSize(width: 200, height: 200)
        greenGermCloud.position = CGPoint(x: self.frame.size.width, y: self.frame.midY)
        greenGermCloud.zPosition = 3
        greenGermCloud.name = "greengerm"
        
        greenGermCloud.physicsBody = SKPhysicsBody(circleOfRadius: greenGermCloud.size.width / 2.3)
        greenGermCloud.physicsBody?.affectedByGravity = false
        greenGermCloud.physicsBody?.categoryBitMask = ColliderType.germs
        greenGermCloud.physicsBody?.collisionBitMask = ColliderType.character
        greenGermCloud.physicsBody?.contactTestBitMask = ColliderType.character
        greenGermCloud.physicsBody?.isDynamic = false
        
        self.addChild(greenGermCloud)
        
        //BananaPeel
        bananaPeel = SKSpriteNode(imageNamed: "banana-peel.png")
        bananaPeel.size = CGSize(width: characterSprite.size.width / 1.7, height: characterSprite.size.height / 1.5)
        bananaPeel.position = CGPoint(x: self.frame.size.width, y: self.frame.minX * 1.15)
        bananaPeel.zPosition = 3
        bananaPeel.name = "banana"
       
        bananaPeel.physicsBody = SKPhysicsBody(circleOfRadius: bananaPeel.size.width / 2)
        bananaPeel.physicsBody?.affectedByGravity = false
        bananaPeel.physicsBody?.categoryBitMask = ColliderType.banana
        bananaPeel.physicsBody?.collisionBitMask = ColliderType.character
        bananaPeel.physicsBody?.contactTestBitMask = ColliderType.character
        bananaPeel.physicsBody?.isDynamic = true
        
        self.addChild(bananaPeel)
        
        //Walking Girl
         
        littleGirl = SKSpriteNode(imageNamed: "jessica-1.png")
        littleGirl.name = "girl"
        littleGirl.size = CGSize(width: littleGirl.size.width / 1.5, height: littleGirl.size.height / 1.5)
        littleGirl.position = CGPoint(x: self.frame.size.width, y: self.frame.minY / 1.70)
        littleGirl.xScale = -1
        littleGirl.color = .green
        littleGirl.zPosition = 4
        littleGirl.colorBlendFactor = 0.30
        
        littleGirl.physicsBody = SKPhysicsBody(circleOfRadius: littleGirl.size.width / 2)
        littleGirl.physicsBody?.affectedByGravity = false
        littleGirl.physicsBody?.categoryBitMask = ColliderType.girl
        littleGirl.physicsBody?.collisionBitMask = ColliderType.character
        littleGirl.physicsBody?.contactTestBitMask = ColliderType.character
        littleGirl.physicsBody?.isDynamic = false
        
        self.addChild(littleGirl)
        
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
        glitter.position = CGPoint(x: 0, y: -250)
        
        glitter.addChild(soap)
        self.addChild(glitter)
    }
    
    func drawBlueGerm() -> Void {
        
        let germShift = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: bgAnimatedInSecs)
        
        let germAnimation = SKAction.repeat(germShift, count: 1)
        
        blueGermCloud.run(germAnimation, completion: blueGermRevert)
    }
    
    func drawGreenGerm() -> Void {
        
        let germShift = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: bgAnimatedInSecs)

        let germRise = SKAction.moveTo(y: self.frame.midY, duration: bgAnimatedInSecs / 2)
        let germFall = SKAction.moveTo(y: characterSprite.position.y, duration: bgAnimatedInSecs / 2)
        
        let germSeq = SKAction.sequence([germFall, germRise])
        
        let germOscillation = SKAction.repeatForever(germSeq)
        let germAnimation = SKAction.repeat(germShift, count: 1)
        
        greenGermCloud.run(germOscillation)
        greenGermCloud.run(germAnimation, completion: greenGermRevert)
    }
    
    func greenGermRevert() {
        
        let germReversion = SKAction.move(by: CGVector(dx: self.frame.width * 2, dy: 0), duration: 0)
        let germRevert = SKAction.repeat(germReversion, count: 1)
        
        greenGermCloud.run(germRevert)
    }
    
    func blueGermRevert() {
        
        let germReversion = SKAction.move(by: CGVector(dx: self.frame.width * 2, dy: 0), duration: 0)
        let germRevert = SKAction.repeat(germReversion, count: 1)
        
        blueGermCloud.run(germRevert)
    }
    
    func drawPeel() -> Void {
        
        let peelShift = SKAction.move(by: CGVector(dx: -self.frame.size.width * 2, dy: 0), duration: bgAnimatedInSecs * 1.3)
        //let peelSequence = SKAction.sequence([peelShift, peelReversion])
        let peelAnimation = SKAction.repeat(peelShift, count: 1)
                
        bananaPeel.run(peelAnimation, completion: revertPeel)
    }
    
    func revertPeel() {
        
        let peelReversion = SKAction.move(by: CGVector(dx: self.frame.size.width * 2, dy: 0), duration: 0)
        let peelRevert = SKAction.repeat(peelReversion, count: 1)
        
        self.bananaPeel.run(peelRevert)
    }
    
    func drawGirl() -> Void {
    
        let girlFrames:[SKTexture] = [SKTexture(imageNamed: "jessica-1.png"), SKTexture(imageNamed: "jessica-2.png"), SKTexture(imageNamed: "jessica-3.png"), SKTexture(imageNamed: "jessica-4.png"), SKTexture(imageNamed: "jessica-5.png"), SKTexture(imageNamed: "jessica-6.png")]

        let runningGirl = SKAction.animate(with: girlFrames, timePerFrame: 0.25)
        let girlShift = SKAction.moveTo(x: -self.frame.size.width * 2, duration: bgAnimatedInSecs * 1.9)
        
        //let girlAction = SKAction.sequence([girlShift, girlReversion])
        
        let moveForever = SKAction.repeat(girlShift, count: 1)
        let runForever = SKAction.repeatForever(runningGirl)
    
        littleGirl.run(runForever, completion: girlReversion)
        littleGirl.run(moveForever)
    }
    
    func girlReversion() {
        
        let girlReversion = SKAction.moveTo(x: self.frame.size.width * 2, duration: 0)
        let peelRevert = SKAction.repeat(girlReversion, count: 1)
        littleGirl.run(peelRevert)
    }
    
    @objc func drawRandom() -> Void {
        
        let number = Int.random(in: 1 ... 3)
        
        switch(number) {
            case 1:
                drawPeel()
            case 2:
                drawBlueGerm()
            case 3:
                drawGirl()
            default:
                print("number other than 1-3....")
            
        }
        print("object spawned.")
    }
    
    func peelDieAnimation() -> Void {

        self.view?.gestureRecognizers?.removeAll()

        bananaPeel.removeAllActions()
        blueGermCloud.removeAllActions()
        characterSprite.removeAllActions()
        littleGirl.removeAllActions()
        
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
        let fall = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.3)
        
        let rotationBackAnim = SKAction.repeat(rotationBack, count: 1)
        let fallAnim = SKAction.repeat(fall, count: 1)
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-16.png")
        characterSprite.run(rotationBackAnim)
        characterSprite.run(fallAnim, completion: endGame)
    }
    
    func germDieAnimation() -> Void {
        
        self.view?.gestureRecognizers?.removeAll()
        characterSprite.physicsBody?.isDynamic = false

        bananaPeel.removeAllActions()
        blueGermCloud.removeAllActions()
        characterSprite.removeAllActions()
        littleGirl.removeAllActions()
        
            
        
        let spinAnim = SKAction.rotate(byAngle: -(2 * CGFloat.pi), duration: 0.3)
        let eatAnim = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: characterSprite.position.y), duration: 0.3)
        
        let spinRepeater = SKAction.repeat(spinAnim, count: 1)
        let eatRepeater = SKAction.repeat(eatAnim, count: 1)
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-15.png")
        
        blueGermCloud.run(eatRepeater)
        characterSprite.run(spinRepeater, completion: disappearCharacter)
    }
    
    
    func disappearCharacter() {
        
        characterSprite.removeAllActions()
        characterSprite.isHidden = true
        endGame()
    }
    
    func girlDieAnimation() -> Void {
        
        self.view?.gestureRecognizers?.removeAll()
        characterSprite.physicsBody?.isDynamic = false
        
        bananaPeel.removeAllActions()
        blueGermCloud.removeAllActions()
        characterSprite.removeAllActions()
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-15.png")
        
        let rotateAnim = SKAction.rotate(byAngle: ((3 * CGFloat.pi) / 2), duration: 0.3)
        
        characterSprite.run(rotateAnim, completion: rotateBack)
    }
    
    func checkPhysics() {

        // Create an array of all the nodes with physicsBodies
        var physicsNodes = [SKNode]()

        //Get all physics bodies
        enumerateChildNodes(withName: "//.") { node, _ in
            if let _ = node.physicsBody {
                physicsNodes.append(node)
            } else {
                print("\(String(describing: node.name)) does not have a physics body so cannot collide or be involved in contacts.")
            }
        }

        //For each node, check it's category against every other node's collion and contctTest bit mask
        for node in physicsNodes {
            let category = node.physicsBody!.categoryBitMask
            // Identify the node by its category if the name is blank
            let name = node.name != nil ? node.name! : "Category \(category)"

            let collisionMask = node.physicsBody!.collisionBitMask
            let contactMask = node.physicsBody!.contactTestBitMask

            // If all bits of the collisonmask set, just say it collides with everything.
            if collisionMask == UInt32.max {
                print("\(name) collides with everything")
            }

            for otherNode in physicsNodes {
                if (node.physicsBody?.isDynamic == false) {
                print("This node \(name) is not dynamic")
            }
                if (node != otherNode) && (node.physicsBody?.isDynamic == true) {
                    let otherCategory = otherNode.physicsBody!.categoryBitMask
                    // Identify the node by its category if the name is blank
                    let otherName = otherNode.name != nil ? otherNode.name! : "Category \(otherCategory)"

                    // If the collisonmask and category match, they will collide
                    if ((collisionMask & otherCategory) != 0) && (collisionMask != UInt32.max) {
                        print("\(name) collides with \(otherName)")
                    }
                    // If the contactMAsk and category match, they will contact
                    if (contactMask & otherCategory) != 0 {print("\(name) notifies when contacting \(otherName)")}
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if(game.IsOver == true)
            {
                if((node?.name == "replaybutton") || (node?.name == "replayshape"))
                {
                    print("replay-button pressed")
                    let scale = SKAction.scale(to: 0.9, duration: 0.3)
                    replayShape.run(scale, completion: startGame)
                }
                
                else if((node?.name == "homebutton") || (node?.name == "homeshape")) {
                    
                    print("home-button pressed")
                    let scale2 = SKAction.scale(to: 0.9, duration: 0.3)
                    homeButtonShape.run(scale2, completion: goToHomeScene)
                }
                
                else if((node?.name == "menubutton") || (node?.name == "menubuttonshape")) {
                    
                    print("menu-button pressed")
                    let scale3 = SKAction.scale(to: 0.9, duration: 0.3)
                    menuButtonShape.run(scale3, completion: goToMenuScene)
                }
            }
        }
        
        func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
            guard let key = presses.first?.key else { return }

            switch key.keyCode {
            case .keyboardR:
                print("Roll dice")
            case .keyboardH:
                print("Show help")
            default:
                super.pressesBegan(presses, with: event)
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
        
        self.showEndingMenu()
        pauseBackgAndPlatform()
        self.temp = 0
        isLevelPassed = false
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
            if(child.isEqual(to: backGBlur))
            {
                for backG in backGBlur.children
                {
                    backG.speed = 0
                }
            }
            
            if((child.name == "platform0") || (child.name == "platform1") || (child.name == "platform2"))
            {
                child.speed = 0
            }
        }
    }
    
    /*
    override func update(_ currentTime: CFTimeInterval) {
        
        
        if(characterSprite.position.x == portal.position.x - 45)
        {
            jumpCharacter()
        }
        
        for child in cameraNode.children {
            
            
            if(child.isEqual(to: backGBlur))
            {
                for backG in backGBlur.children {
                    
                    backG.position.x.round(.down)
                    backG.position.y.round(.down)
                }
            }
            
            if((child.name == "platform0") || (child.name == "platform1"))
            {
                child.position.x.round(.up)
                child.position.y.round(.up)
            }
        }
    }
 */
}
