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
}

struct game {
    
    static var IsOver : Bool = false
    static var contactDetected: Bool = false
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let playerSpeedPerFrame = 0.25
    let playerJumpPerFrame = 1.0
    let maxTimeMoving: CGFloat = 2
    let bgAnimatedInSecs: TimeInterval = 3
    let MIN_THRESHOLD_MS: Double = 1000
    
    var effectsNode = SKEffectNode()
    var characterSprite: SKSpriteNode = SKSpriteNode()
    var background: SKSpriteNode = SKSpriteNode()
    var platform: SKSpriteNode = SKSpriteNode()
    var house: SKSpriteNode = SKSpriteNode()
    var germCloud: SKSpriteNode = SKSpriteNode()
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

        self.physicsWorld.contactDelegate = self
        initializeGame()
        
        //to-do: Make these obstacle objects random
}
    func initializeGame() -> Void {
            
        drawBackground()
        drawPlatform()
        drawCharacter()
        initObjectPhysics()
        
        //timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(drawRandom), userInfo: nil, repeats: true)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(jumpUp))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(slideDown))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
        
    }

    func didBegin(_ contact: SKPhysicsContact) {
        
        self.view?.gestureRecognizers?.removeAll()
        game.contactDetected = true
        
        print("yo")
        
        let nodeA = contact.bodyA
        let nodeB = contact.bodyB
        
        if(((nodeA.node?.name == "character") && (nodeB.node?.name == "banana")) || ((nodeA.node?.name == "banana") && (nodeB.node?.name == "character")))
        {
            peelDieAnimation()
        }
        else if(((nodeA.node?.name == "character") && (nodeB.node?.name == "germ")) || ((nodeA.node?.name == "germ") && (nodeB.node?.name == "character")))
        {
            germDieAnimation()
        }
        else
        {
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
    
        if((lastTime > 0) && (currentTime - lastTime) <= 1000)
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
        nextLevelShape.isUserInteractionEnabled = true
        nextLevelShape.fillColor = .white
        nextLevelShape.isAntialiased = true
        nextLevelShape.strokeColor = .black
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
        homeButtonShape.isUserInteractionEnabled = true
        homeButtonShape.fillColor = .white
        homeButtonShape.isAntialiased = true
        homeButtonShape.strokeColor = .black
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
        menuButtonShape.isUserInteractionEnabled = true
        menuButtonShape.fillColor = .white
        menuButtonShape.isAntialiased = true
        menuButtonShape.strokeColor = .black
        menuButtonShape.position = CGPoint(x: self.frame.midX + 200, y: self.frame.midY + 50)
        menuButtonShape.addChild(menuButton)
        menuButtonShape.zPosition = 5
        
        self.addChild(menuButtonShape)
        
    }
    
     func blurWithCompletion() {
        
        let filter = CIFilter(name: "CIGaussianBlur")
        // Set the blur amount. Adjust this to achieve the desired effect
        let blurAmount = 10.0
        filter?.setValue(blurAmount, forKey: kCIInputRadiusKey)

        effectsNode.filter = filter
        effectsNode.position = self.view!.center
        effectsNode.blendMode = .alpha
        
        
        /*
        for child in self.children
        {
            let names: [String] = ["replaybutton", "replayshape", "nextlevelbutton", "nextlevelshape", "homebutton", "homebuttonshape"]
            
            
            if(!names.contains(child.name!))
            {
                child.run(effectsNode)
            }
        }
        self.addChild(effectsNode)
 */
    }
    
    func showEndingMenu() -> Void {
        
        gameOverDisplay = SKShapeNode(rect: CGRect(x: -self.frame.width, y: self.frame.midY - 20, width: self.frame.width * 2, height: 300))
        gameOverDisplay.fillColor = .black
        gameOverDisplay.alpha = 0.5
                
        levelAlert = SKLabelNode(fontNamed: "CarbonBl-Regular")
        levelAlert.fontColor = .white
        levelAlert.fontSize = 72
        //gameStatusAlert.alpha = 1.0
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
        
        jumpCharacter()
        
        if(!game.contactDetected)
        {
            if(game.contactDetected)
            {
                print("herio")
                return
            }
            let seconds = 0.9
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
                if(game.contactDetected)
                {
                    return
                }
                else
                {
                    if(game.contactDetected)
                    {
                        return
                    }
                    self.resumeRunning()
                }
            }
        }
    }
    
    @objc func slideDown(sender: UIButton!) {
                
        if(!isReady())
        {
            print("Cooldown on button")
            return
        }
        print("jumpDown")
        pauseRunning()
        duckCharacter()
        
        if(!game.contactDetected)
        {
            let seconds = 0.9
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
                if(game.contactDetected)
                {
                    return
                }
                else
                {
                    self.resumeRunning()
                }
            }
        }
    }
    
    func drawBackground() -> Void{
        
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
            background.size.height = self.frame.height
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
        
        
        //Physics Body
        characterSprite.physicsBody = SKPhysicsBody(circleOfRadius: characterSprite.size.width / 2.5)
        characterSprite.physicsBody?.affectedByGravity = false
        characterSprite.physicsBody?.categoryBitMask = ColliderType.character
        characterSprite.physicsBody?.collisionBitMask = ColliderType.banana | ColliderType.germs
        characterSprite.physicsBody?.contactTestBitMask = ColliderType.banana | ColliderType.germs
        characterSprite.physicsBody?.usesPreciseCollisionDetection = true
        characterSprite.physicsBody?.isDynamic = true
        
        
        
        
        self.addChild(characterSprite)
        
        characterSprite.zPosition = 2;

        
        
        characterSprite.run(mainRepeater, withKey: "running")
        
        /*
        let seconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAction(forKey: "running")
            self.jumpCharacter()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 1.0)
        {
            self.characterSprite.run(mainRepeater, withKey: "running")
        }
 */

    }
    
    func jumpCharacter() -> Void{
                
        if(game.contactDetected)
        {
            return
        }
        let upAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.midY), duration: 0.5)
        let downAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.5)
    
        let upRepeater = SKAction.repeat(upAction, count: 1)
        let downRepeater = SKAction.repeat(downAction, count: 1)
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-12.png")
        characterSprite.run(upRepeater, withKey: "up")
        
        
        if(game.contactDetected)
        {
            characterSprite.removeAction(forKey: "up")
            print("reached")
            return
        }
        
        let seconds = 0.50
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            self.characterSprite.texture = SKTexture(imageNamed: "bobby-13.png")
            self.characterSprite.removeAction(forKey: "up")
            self.characterSprite.run(downRepeater, withKey: "down")
            
            if(game.contactDetected)
            {
                self.characterSprite.removeAction(forKey: "up")
                self.characterSprite.removeAction(forKey: "down")
                self.characterSprite.texture = SKTexture(imageNamed: "bobby-16.png")
                print("reached")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds){
                
                if(game.contactDetected)
                {
                    self.characterSprite.removeAction(forKey: "down")
                    self.characterSprite.texture = SKTexture(imageNamed: "bobby-16.png")
                    print("reached")
                    return
                }
                self.characterSprite.removeAction(forKey: "down")
                //self.characterSprite.texture = SKTexture(imageNamed: "row-1-col-1.png")
            }
        }
    }
    
    func duckCharacter() -> Void {
        
       let duckFrames:[SKTexture] = [SKTexture(imageNamed: "bobby-5.png")]
                        
       let duckAnimation = SKAction.animate(with: duckFrames, timePerFrame: 0.25)
       let yShift = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: characterSprite.position.y - 15), duration: 0.5)
       let yRevert = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: characterSprite.position.y), duration: 0.3)
        
       let repeatDuck = SKAction.repeatForever(duckAnimation)
       let repeatYShift = SKAction.repeatForever(yShift)
       let repeatYRevert = SKAction.repeat(yRevert, count: 1)

       characterSprite.run(repeatDuck, withKey: "ducking")
       characterSprite.run(repeatYShift, withKey: "yshift")

       var seconds = 0.5
       DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
       {
            self.characterSprite.removeAction(forKey: "ducking")
            self.characterSprite.removeAction(forKey: "yshift")
            self.characterSprite.run(repeatYRevert, withKey: "yrevert")
            seconds = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
            
            }
       }
    }
    
    func initObjectPhysics() -> Void{
        
        //GermCloud
        germCloud = SKSpriteNode(imageNamed: "blue-germ-1")
        germCloud.size = CGSize(width: 200, height: 200)
        germCloud.position = CGPoint(x: self.frame.size.width, y: (self.frame.minY / 2.65))
        germCloud.zPosition = 3
        germCloud.name = "germ"
        
        germCloud.physicsBody = SKPhysicsBody(circleOfRadius: germCloud.size.width / 2.3)
        germCloud.physicsBody?.affectedByGravity = false
        germCloud.physicsBody?.categoryBitMask = ColliderType.germs
        germCloud.physicsBody?.collisionBitMask = ColliderType.character
        germCloud.physicsBody?.contactTestBitMask = ColliderType.character
        germCloud.physicsBody?.isDynamic = false
        
        self.addChild(germCloud)
        
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
        littleGirl.colorBlendFactor = 0.30
        
        littleGirl.physicsBody = SKPhysicsBody(circleOfRadius: littleGirl.size.width / 2)
        littleGirl.physicsBody?.affectedByGravity = false
        littleGirl.physicsBody?.categoryBitMask = ColliderType.girl
        littleGirl.physicsBody?.collisionBitMask = ColliderType.character
        littleGirl.physicsBody?.contactTestBitMask = ColliderType.character
        littleGirl.physicsBody?.isDynamic = false
        
        self.addChild(littleGirl)
    }
    
    func drawGerm() -> Void {
        
        let germShift = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: bgAnimatedInSecs)
        let germReversion = SKAction.move(by: CGVector(dx: self.frame.width * 2, dy: 0), duration: 0)
        
        //let germSequence = SKAction.sequence([germShift, germReversion])
        let germAnimation = SKAction.repeat(germShift, count: 1)
        let germRevert = SKAction.repeat(germReversion, count: 1)

        germCloud.run(germAnimation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + bgAnimatedInSecs)
        {
            self.germCloud.run(germRevert)
        }
    }
    
    func drawPeel() -> Void {
        
        let peelShift = SKAction.move(by: CGVector(dx: -self.frame.size.width * 2, dy: 0), duration: bgAnimatedInSecs * 1.3)
        let peelReversion = SKAction.move(by: CGVector(dx: self.frame.size.width * 2, dy: 0), duration: 0)
        
        //let peelSequence = SKAction.sequence([peelShift, peelReversion])
        let peelAnimation = SKAction.repeat(peelShift, count: 1)
        let peelRevert = SKAction.repeat(peelReversion, count: 1)
                
        bananaPeel.run(peelAnimation, withKey: "banana")
        DispatchQueue.main.asyncAfter(deadline: .now() + bgAnimatedInSecs * 1.3)
        {
            self.bananaPeel.run(peelRevert)
        }
    }
    
    func drawGirl() -> Void {
    
        let girlFrames:[SKTexture] = [SKTexture(imageNamed: "jessica-1.png"), SKTexture(imageNamed: "jessica-2.png"), SKTexture(imageNamed: "jessica-3.png"), SKTexture(imageNamed: "jessica-4.png"), SKTexture(imageNamed: "jessica-5.png")]

        let runningGirl = SKAction.animate(with: girlFrames, timePerFrame: 0.25)
        let girlShift = SKAction.moveTo(x: -self.frame.size.width * 2, duration: bgAnimatedInSecs * 1.3)
        let girlReversion = SKAction.moveTo(x: self.frame.size.width * 2, duration: 0)
        
        //let girlAction = SKAction.sequence([girlShift, girlReversion])
        
        let moveForever = SKAction.repeat(girlShift, count: 1)
        let peelRevert = SKAction.repeat(girlReversion, count: 1)
        let runForever = SKAction.repeatForever(runningGirl)
    
        littleGirl.run(runForever)
        littleGirl.run(moveForever)
        DispatchQueue.main.asyncAfter(deadline: .now() + bgAnimatedInSecs * 1.3)
        {
            self.littleGirl.run(peelRevert)
        }
    }
    
    @objc func drawRandom() -> Void {
        
        let number = Int.random(in: 1 ... 3)
        
        switch(number) {
            case 1:
                drawPeel()
            case 2:
                drawGerm()
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
        germCloud.removeAllActions()
        characterSprite.removeAllActions()
        littleGirl.removeAllActions()
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-15.png")
        
        let bananaSlide = SKAction.move(to: CGPoint(x: self.frame.size.width * 2, y: self.frame.minX * 1.15), duration: 0.5)
        let bananaSlideAnim = SKAction.repeat(bananaSlide, count: 1)
        
        let rotation = SKAction.rotate(byAngle: ((3 * CGFloat.pi) / 2), duration: 0.3)
        let rotationBack = SKAction.rotate(byAngle: (-(3 * CGFloat.pi) / 2), duration: 0)
        let fall = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.1)
        
        let fallAnim = SKAction.repeat(fall, count: 1)
        let rotationAnim = SKAction.repeat(rotation, count: 1)
        let rotationBackAnim = SKAction.repeat(rotationBack, count: 1)
                
        characterSprite.run(rotationAnim, withKey: "rotate")
        bananaPeel.run(bananaSlideAnim, withKey: "bananaslide")
        
        let seconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            
            self.characterSprite.run(rotationBackAnim, withKey: "rotateback")
            self.characterSprite.run(fallAnim, withKey: "fall")
            self.characterSprite.texture = SKTexture(imageNamed: "bobby-16.png")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
            {
                self.endGame()
            }
        }
    }
    
    func germDieAnimation() -> Void {
        
        self.view?.gestureRecognizers?.removeAll()
        characterSprite.physicsBody?.isDynamic = false

        bananaPeel.removeAllActions()
        germCloud.removeAllActions()
        characterSprite.removeAllActions()
        littleGirl.removeAllActions()
        
            
        
        let spinAnim = SKAction.rotate(byAngle: -(2 * CGFloat.pi), duration: 0.3)
        let eatAnim = SKAction.move(to: CGPoint(x: characterSprite.position.x, y: characterSprite.position.y), duration: 0.3)
        
        let spinRepeater = SKAction.repeatForever(spinAnim)
        let eatRepeater = SKAction.repeatForever(eatAnim)
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-15.png")
        
        characterSprite.run(spinRepeater, withKey: "spin")
        germCloud.run(eatRepeater, withKey: "eat")
        
        let seconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAllActions()
            self.characterSprite.isHidden = true
            self.endGame()
        }
    }
    
    func girlDieAnimation() -> Void {
        
        self.view?.gestureRecognizers?.removeAll()
        characterSprite.physicsBody?.isDynamic = false
        
        bananaPeel.removeAllActions()
        germCloud.removeAllActions()
        characterSprite.removeAllActions()
        
        characterSprite.texture = SKTexture(imageNamed: "bobby-15.png")
        
        let rotateAnim = SKAction.rotate(byAngle: ((3 * CGFloat.pi) / 2), duration: 0.3)
        let reversionAnim = SKAction.rotate(byAngle: -((3 * CGFloat.pi) / 2), duration: 0)
        let fall = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.3)

        let fallAnim = SKAction.repeat(fall, count: 1)
        
        characterSprite.run(rotateAnim, withKey: "rotation")
        
        let seconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAction(forKey: "rotation")
            self.characterSprite.run(reversionAnim, withKey: "rev")
            self.characterSprite.texture = SKTexture(imageNamed: "bobby-16.png")
            self.characterSprite.run(fallAnim, withKey: "fallanim")
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
                self.endGame()
            }
        }
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
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(game.IsOver == true)
        {
            startGame()
        }
    }
     */
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if(game.IsOver == true)
            {
                if((node?.name == "replaybutton") || (node?.name == "replayshape"))
                {
                    print("pressed")
                    let scale = SKAction.scale(to: 0.9, duration: 0)
                    replayShape.run(scale)
                    replayButton.run(scale)
                    
                    let seconds = 0.01
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
                    {
                        self.startGame()
                    }
                }
            }
        }
    }
    
    
    func startGame() -> Void{
        
        cleanUp()
        scene!.shouldEnableEffects = false
        initializeGame()
        self.speed = 1
        game.contactDetected = false
        game.IsOver = false
    }
    
     func endGame() -> Void{
        
        
        blurWithCompletion()
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.showEndingMenu()
            self.speed = 0
            self.timer.invalidate()
            game.IsOver = true
        }
    }
    
    func cleanUp() -> Void {
        
        let children = self.children
        
        for child in children
        {
            if let spriteNode = child as? SKSpriteNode{
                
                if(spriteNode.name == "background" || spriteNode.name == "platform")
                {
                    spriteNode.texture = nil
                }
                spriteNode.removeAllActions()
            }
        }
        self.removeAllChildren()
    }

    /*
func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
 */
}

