//
//  GameScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/13/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import SpriteKit
import GameplayKit

struct ColliderType
{
    static let none: UInt32 = 0x1 << 0
    static let character: UInt32 = 0x1 << 1
    static let banana: UInt32 = 0x1 << 2
    static let germs: UInt32 = 0x1 << 3
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
    //var scoreLabel: SKSpriteNode = SKSpriteNode()
    var germCloud: SKSpriteNode = SKSpriteNode()
    var bananaPeel: SKSpriteNode = SKSpriteNode()
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
        drawBackground()
        drawPlatform()
        drawCharacter()
        initObstaclePhysics()
        //drawGerm()
        drawPeel()
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
        peelDieAnimation()
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
                self.resumeRunning()
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
        let seconds = 0.9
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.resumeRunning()
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
        
        let runAnimations:[SKTexture] = [SKTexture(imageNamed: "row-1-col-1.png"), SKTexture(imageNamed: "row-1-col-2.png"), SKTexture(imageNamed: "row-1-col-3.png"), SKTexture(imageNamed: "row-2-col-1.png"), SKTexture(imageNamed: "row-2-col-2.png"), SKTexture(imageNamed: "row-2-col-3.png")]
        
        let mainAnimated = SKAction.animate(with: runAnimations, timePerFrame: 0.25)
        let mainRepeater = SKAction.repeatForever(mainAnimated)
        
        characterSprite = SKSpriteNode(imageNamed: "row-1-col-1.png")
        characterSprite.name = "character"
        characterSprite.position = CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70)
        
        
        //Physics Body
        characterSprite.physicsBody = SKPhysicsBody(circleOfRadius: characterSprite.size.width / 2)
        characterSprite.physicsBody?.affectedByGravity = false
        characterSprite.physicsBody?.categoryBitMask = ColliderType.character
        characterSprite.physicsBody?.collisionBitMask = ColliderType.banana | ColliderType.germs
        characterSprite.physicsBody?.contactTestBitMask = ColliderType.banana | ColliderType.germs
        characterSprite.physicsBody?.usesPreciseCollisionDetection = true
        characterSprite.physicsBody?.isDynamic = false
        
        
        
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
        
        characterSprite.texture = SKTexture(imageNamed: "row-3-col-1.png")
        characterSprite.run(upRepeater, withKey: "up")
        
        
        if(startedContact)
        {
            return
        }
        
        let seconds = 0.50
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            self.characterSprite.texture = SKTexture(imageNamed: "row-3-col-2.png")
            self.characterSprite.removeAction(forKey: "up")
            self.characterSprite.run(downRepeater, withKey: "down")
            
            if(self.startedContact)
            {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds){
                
                if(self.startedContact)
                {
                    return
                }
                self.characterSprite.removeAction(forKey: "down")
                //self.characterSprite.texture = SKTexture(imageNamed: "row-1-col-1.png")
            }
        }
    }
    
    func duckCharacter() -> Void {
        
       let duckFrames:[SKTexture] = [SKTexture(imageNamed: "row-4-col-1.png")]
        
       characterSprite.texture = SKTexture(imageNamed: "row-4-col-1.png")
    
        let duckAnimation = SKAction.animate(with: duckFrames, timePerFrame: 0.25)
        
        let repeatDuck = SKAction.repeatForever(duckAnimation)

        characterSprite.run(repeatDuck, withKey: "ducking")
        
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAction(forKey: "ducking")
            //self.characterSprite.texture = SKTexture(imageNamed: "row-1-col-1.png")
        }
    }
    
    func initObstaclePhysics() -> Void{
        
        
        /*
        germCloud = SKSpriteNode(imageNamed: "Clipart-Email-10350186")
        germCloud.size = CGSize(width: 200, height: 200)
        germCloud.name = "germ"
        germCloud.physicsBody = SKPhysicsBody(rectangleOf: germCloud.size)
        germCloud.physicsBody?.affectedByGravity = false
        germCloud.physicsBody?.categoryBitMask = ColliderType.germs
        germCloud.physicsBody?.collisionBitMask = ColliderType.character
        germCloud.physicsBody?.contactTestBitMask = ColliderType.character
        germCloud.physicsBody?.isDynamic = true
        
        self.addChild(germCloud)
 */
        
        bananaPeel = SKSpriteNode(imageNamed: "banana-peel-2504671_640.png")
        bananaPeel.size = CGSize(width: 100, height: 100)
        bananaPeel.name = "banana"
        bananaPeel.physicsBody = SKPhysicsBody(circleOfRadius: bananaPeel.size.width / 2)
        bananaPeel.physicsBody?.affectedByGravity = false
        bananaPeel.physicsBody?.categoryBitMask = ColliderType.banana
        bananaPeel.physicsBody?.collisionBitMask = ColliderType.character
        bananaPeel.physicsBody?.contactTestBitMask = ColliderType.character
        bananaPeel.physicsBody?.usesPreciseCollisionDetection = true
        bananaPeel.physicsBody?.isDynamic = true
        
        self.addChild(bananaPeel)
    }
    
    func drawGerm() -> Void {
        
        let germShift = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: bgAnimatedInSecs)
        let germReversion = SKAction.move(by: CGVector(dx: self.frame.width * 2, dy: 0), duration: 0)
        //let germShift = SKAction.move(to: CGPoint(x: -self.frame.size.width, y: self.frame.minY / 3), duration: bgAnimatedInSecs)
        
        let germSequence = SKAction.sequence([germShift, germReversion])
        let germAnimation = SKAction.repeatForever(germSequence)
        
        
        //germCloud.texture = SKTexture(imageNamed: "Clipart-Email-10350186")
        germCloud.position = CGPoint(x: self.frame.size.width, y: (self.frame.minY / 2.65))
        germCloud.zPosition = 3
        
        germCloud.run(germAnimation)
    }
    
    func drawPeel() -> Void {
        
        let peelShift = SKAction.move(by: CGVector(dx: -self.frame.size.width * 2, dy: 0), duration: bgAnimatedInSecs / 2)
        let peelReversion = SKAction.move(by: CGVector(dx: self.frame.size.width * 2, dy: 0), duration: 0)
        
        let peelSequence = SKAction.sequence([peelShift, peelReversion])
        let peelAnimation = SKAction.repeatForever(peelSequence)
        
        //bananaPeel.texture = SKTexture(imageNamed: "banana-peel-2504671_640.png")
        bananaPeel.size = CGSize(width: characterSprite.size.width, height: characterSprite.size.height)
        bananaPeel.position = CGPoint(x: self.frame.size.width, y: self.frame.minX * 1.15)
        bananaPeel.zPosition = 3
                
        bananaPeel.run(peelAnimation)
    }
    
    func peelDieAnimation() -> Void {
        
        bananaPeel.removeAllActions()
        germCloud.removeAllActions()
        characterSprite.removeAllActions()
        
        characterSprite.texture = SKTexture(imageNamed: "row-4-col-2.png")
        
        let bananaSlide = SKAction.move(to: CGPoint(x: self.frame.size.width * 2, y: self.frame.minX * 1.15), duration: 0.5)
        let bananaSlideAnim = SKAction.repeat(bananaSlide, count: 1)
        
        let rotation = SKAction.rotate(byAngle: ((3 * CGFloat.pi) / 2), duration: 0.5)
        let rotationBack = SKAction.rotate(byAngle: (-(3 * CGFloat.pi) / 2), duration: 0)
        let fall = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.5)
        
        let fallAnim = SKAction.repeat(fall, count: 1)
        let rotationAnim = SKAction.repeat(rotation, count: 1)
        let rotationBackAnim = SKAction.repeat(rotationBack, count: 1)
                
        characterSprite.run(rotationAnim)
        bananaPeel.run(bananaSlideAnim)
        
        let seconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            
            self.characterSprite.run(rotationBackAnim)
            self.characterSprite.run(fallAnim)
            self.characterSprite.texture = SKTexture(imageNamed: "row-4-col-3.png")
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

