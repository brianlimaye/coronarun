//
//  GameScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/13/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//
//0. Implement the app delegate methods (ex. Hit home button after dying)
//1. Add a replay button after dying.
//2. Randomize objects
//3. Implement time-based closing animation
//4  Score board
//5. Make sure it works on all devices
//6. Make sure orientation is dynamic


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

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let playerSpeedPerFrame = 0.25
    let playerJumpPerFrame = 1.0
    let maxTimeMoving: CGFloat = 2
    let bgAnimatedInSecs: TimeInterval = 3
    let MIN_THRESHOLD_MS: Double = 1000
    
    var characterSprite: SKSpriteNode = SKSpriteNode()
    var background: SKSpriteNode = SKSpriteNode()
    var platform: SKSpriteNode = SKSpriteNode()
    var house: SKSpriteNode = SKSpriteNode()
    //var scoreLabel: SKSpriteNode = SKSpriteNode()
    var germCloud: SKSpriteNode = SKSpriteNode()
    var bananaPeel: SKSpriteNode = SKSpriteNode()
    var littleGirl: SKSpriteNode = SKSpriteNode()
    var score: Int = 0
    var lives: Int = 1
    var gameOver: Bool = false
    //var gameOverDisplay: SKLabelNode = SKLabelNode()
    var timer: Timer = Timer()
    var runAction: SKAction = SKAction()
    var lastTime: Double = 0
    var startedContact: Bool = false

    override func didMove(to view: SKView) -> Void {
        if(self.isPaused)
        {
            self.isPaused = false
        }

        self.physicsWorld.contactDelegate = self
        //createSceneContent()
        drawBackground()
        drawPlatform()
        drawCharacter()
        
        initObjectPhysics()
        //drawGirl()
        drawGerm()
        //to-do: Make these objects random
        //drawPeel()
        checkPhysics()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(jumpUp))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(slideDown))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
}

    func didBegin(_ contact: SKPhysicsContact) {
        
        startedContact = true
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
        
        startedContact = false
    }

    @objc func timerAction(){
       print("timer fired!")
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
    
    func closingScene() -> Void{
                
        house = SKSpriteNode(imageNamed: "imageedit_1_5329322170.png")
        house.size = CGSize(width: house.size.width / 3, height: house.size.height / 3)
        house.position = CGPoint(x: self.frame.width * 2, y: self.frame.minY / 1.9)
        
        self.addChild(house)
        
        let standingFrames:[SKTexture] = [SKTexture(imageNamed: "updated1.png"), SKTexture(imageNamed: "updated2.png"), SKTexture(imageNamed: "updated3.png"), SKTexture(imageNamed: "updated4.png")]
        
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
                self.characterSprite.texture = SKTexture(imageNamed: "updated1.png")
                self.characterSprite.run(repeatingStanding)
                DispatchQueue.main.asyncAfter(deadline: .now() + (seconds * 6))
                {
                    self.isPaused = true
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
        
        if(!startedContact)
        {
            let seconds = 0.9
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
                if(self.startedContact)
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
    
    @objc func slideDown(sender: UIButton!) {
                
        if(!isReady())
        {
            print("Cooldown on button")
            return
        }
        print("jumpDown")
        pauseRunning()
        duckCharacter()
        
        if(!startedContact)
        {
            let seconds = 0.9
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
                if(self.startedContact)
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

    func initializeGame() -> Void{
            
            timer = Timer.scheduledTimer(
                timeInterval: 3,
                 target: self,
                 selector: #selector(timerAction),
                 userInfo: nil,
                 repeats: true
            )
        
            //drawBackground()
            //drawCharacter()
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

            self.addChild(background);

            i += 1

            // Set background first
            background.zPosition = -2;
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
        
        let runAnimations:[SKTexture] = [SKTexture(imageNamed: "updated6.png"), SKTexture(imageNamed: "updated7.png"), SKTexture(imageNamed: "updated8.png"), SKTexture(imageNamed: "updated9.png"), SKTexture(imageNamed: "updated10.png"), SKTexture(imageNamed: "updated11.png")]
        
        let mainAnimated = SKAction.animate(with: runAnimations, timePerFrame: 0.2)
        let mainRepeater = SKAction.repeatForever(mainAnimated)
        
        characterSprite = SKSpriteNode(imageNamed: "updated6.png")
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
                
        let upAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.midY), duration: 0.5)
        let downAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.5)
    
        let upRepeater = SKAction.repeat(upAction, count: 1)
        let downRepeater = SKAction.repeat(downAction, count: 1)
        
        characterSprite.texture = SKTexture(imageNamed: "updated12.png")
        characterSprite.run(upRepeater, withKey: "up")
        
        
        if(startedContact)
        {
            characterSprite.removeAction(forKey: "up")
            return
        }
        
        let seconds = 0.50
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            self.characterSprite.texture = SKTexture(imageNamed: "updated13.png")
            self.characterSprite.removeAction(forKey: "up")
            self.characterSprite.run(downRepeater, withKey: "down")
            
            if(self.startedContact)
            {
                self.characterSprite.removeAction(forKey: "up")
                self.characterSprite.removeAction(forKey: "down")
                self.characterSprite.texture = SKTexture(imageNamed: "updated16.png")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds){
                
                if(self.startedContact)
                {
                    self.characterSprite.removeAction(forKey: "down")
                    self.characterSprite.texture = SKTexture(imageNamed: "updated16.png")
                    return
                }
                self.characterSprite.removeAction(forKey: "down")
                //self.characterSprite.texture = SKTexture(imageNamed: "row-1-col-1.png")
            }
        }
    }
    
    func duckCharacter() -> Void {
        
       let duckFrames:[SKTexture] = [SKTexture(imageNamed: "updated5.png")]
                        
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
        germCloud = SKSpriteNode(imageNamed: "Clipart-Email-10350186")
        germCloud.size = CGSize(width: 200, height: 200)
        germCloud.name = "germ"
        germCloud.physicsBody = SKPhysicsBody(circleOfRadius: germCloud.size.width / 2.3)
        germCloud.physicsBody?.affectedByGravity = false
        germCloud.physicsBody?.categoryBitMask = ColliderType.germs
        germCloud.physicsBody?.collisionBitMask = ColliderType.character
        germCloud.physicsBody?.contactTestBitMask = ColliderType.character
        germCloud.physicsBody?.isDynamic = false
        
        self.addChild(germCloud)
        
        
        //BananaPeel
        bananaPeel = SKSpriteNode(imageNamed: "banana-peel-2504671_640.png")
        bananaPeel.size = CGSize(width: characterSprite.size.width / 1.7, height: characterSprite.size.height / 1.5)
        bananaPeel.name = "banana"
        bananaPeel.physicsBody = SKPhysicsBody(circleOfRadius: bananaPeel.size.width / 2)
        bananaPeel.physicsBody?.affectedByGravity = false
        bananaPeel.physicsBody?.categoryBitMask = ColliderType.banana
        bananaPeel.physicsBody?.collisionBitMask = ColliderType.character
        bananaPeel.physicsBody?.contactTestBitMask = ColliderType.character
        bananaPeel.physicsBody?.isDynamic = true
        
        //self.addChild(bananaPeel)
        
        //Walking Girl
         
        littleGirl = SKSpriteNode(imageNamed: "step1.png")
        littleGirl.name = "girl"
        littleGirl.size = CGSize(width: littleGirl.size.width / 1.1, height: characterSprite.size.height / 1.1)
        littleGirl.xScale = -1
        littleGirl.color = .clear
        littleGirl.colorBlendFactor = 0.05
        
        littleGirl.physicsBody = SKPhysicsBody(circleOfRadius: littleGirl.size.width / 2)
        littleGirl.physicsBody?.affectedByGravity = false
        littleGirl.physicsBody?.categoryBitMask = ColliderType.girl
        littleGirl.physicsBody?.collisionBitMask = ColliderType.character
        littleGirl.physicsBody?.contactTestBitMask = ColliderType.character
        littleGirl.physicsBody?.isDynamic = false
        
        //self.addChild(littleGirl)
    }
    
    func drawGerm() -> Void {
        
        let germShift = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: bgAnimatedInSecs * 1.3)
        let germReversion = SKAction.move(by: CGVector(dx: self.frame.width * 2, dy: 0), duration: 0)
        
        let germSequence = SKAction.sequence([germShift, germReversion])
        let germAnimation = SKAction.repeatForever(germSequence)
        
        
        germCloud.position = CGPoint(x: self.frame.size.width, y: (self.frame.minY / 2.65))
        germCloud.zPosition = 3
        
        germCloud.run(germAnimation, withKey: "germ")
    }
    
    func drawPeel() -> Void {
        
        let peelShift = SKAction.move(by: CGVector(dx: -self.frame.size.width * 2, dy: 0), duration: bgAnimatedInSecs / 2)
        let peelReversion = SKAction.move(by: CGVector(dx: self.frame.size.width * 2, dy: 0), duration: 0)
        
        let peelSequence = SKAction.sequence([peelShift, peelReversion])
        let peelAnimation = SKAction.repeatForever(peelSequence)
        
        bananaPeel.position = CGPoint(x: self.frame.size.width, y: self.frame.minX * 1.15)
        bananaPeel.zPosition = 3
                
        bananaPeel.run(peelAnimation, withKey: "banana")
    }
    
    func drawGirl() -> Void {
    
        let girlFrames:[SKTexture] = [SKTexture(imageNamed: "f1.png"), SKTexture(imageNamed: "f2.png"), SKTexture(imageNamed: "f3.png"), SKTexture(imageNamed: "f4.png"), SKTexture(imageNamed: "f5.png")]

        let runningGirl = SKAction.animate(with: girlFrames, timePerFrame: 0.25)
        let girlShift = SKAction.moveTo(x: -self.frame.size.width * 2, duration: bgAnimatedInSecs * 1.3)
        let girlReversion = SKAction.moveTo(x: self.frame.size.width * 2, duration: 0)
        
        let boyAction = SKAction.sequence([girlShift, girlReversion])
        
        let moveForever = SKAction.repeatForever(boyAction)
        let runForever = SKAction.repeatForever(runningGirl)
        
        littleGirl.position = CGPoint(x: self.frame.size.width, y: self.frame.minY / 1.70)

        littleGirl.run(runForever)
        littleGirl.run(moveForever)
       
    }
    
    func peelDieAnimation() -> Void {

        self.view?.gestureRecognizers?.removeAll()

        bananaPeel.removeAllActions()
        germCloud.removeAllActions()
        characterSprite.removeAllActions()
        littleGirl.removeAllActions()
        
        characterSprite.texture = SKTexture(imageNamed: "updated15.png")
        
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
            self.characterSprite.texture = SKTexture(imageNamed: "updated16.png")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
            {
                self.isPaused = true
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
        
        characterSprite.texture = SKTexture(imageNamed: "updated15.png")
        
        characterSprite.run(spinRepeater, withKey: "spin")
        germCloud.run(eatRepeater, withKey: "eat")
        
        let seconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAllActions()
            self.characterSprite.isHidden = true
            self.isPaused = true
        }
    }
    
    func girlDieAnimation() -> Void {
        
        self.view?.gestureRecognizers?.removeAll()
        characterSprite.physicsBody?.isDynamic = false
        
        bananaPeel.removeAllActions()
        germCloud.removeAllActions()
        characterSprite.removeAllActions()
        littleGirl.removeAllActions()
        
        characterSprite.texture = SKTexture(imageNamed: "updated15.png")
        
        let rotateAnim = SKAction.rotate(byAngle: ((3 * CGFloat.pi) / 2), duration: 0.3)
        let reversionAnim = SKAction.rotate(byAngle: -((3 * CGFloat.pi) / 2), duration: 0)
        let changeTexture = SKAction.setTexture(SKTexture(imageNamed: "updated16.png"))
        let fall = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.3)

        let fallAnim = SKAction.repeat(fall, count: 1)
        
        characterSprite.run(rotateAnim, withKey: "rotation")
        
        let seconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAction(forKey: "rotation")
            self.characterSprite.run(reversionAnim, withKey: "rev")
            self.characterSprite.run(changeTexture, withKey: "texture")
            self.characterSprite.run(fallAnim, withKey: "fallanim")
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
            {
                self.isPaused = true
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

