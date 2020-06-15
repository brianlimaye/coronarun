//
//  HomeScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/31/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import Foundation
import SpriteKit

var cameraNode: SKCameraNode = SKCameraNode()
var backGBlur: SKEffectNode = SKEffectNode()


class HomeScene: SKScene
{
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
    var clickToStart: SKLabelNode = SKLabelNode()
    
    override func didMove(to view: SKView) {

        if(cameraNode.children.count > 0)
        {
            cameraNode.removeAllChildren()
        }
        
        initBlurEffect()
        drawGreenSplat()
        initTitleScreen()
        addBackgFreezeFrame()
        addPlatformFreezeFrame()
        addIdleCharacter()
        drawSoundButton()
    }
    
    func initBlurEffect() {
        
        print("reach")
        let filter = CIFilter(name: "CIGaussianBlur")
        // Set the blur amount. Adjust this to achieve the desired effect
        let blurAmount = 20.0
        filter?.setValue(blurAmount, forKey: kCIInputRadiusKey)

        backGBlur.filter = filter
        backGBlur.shouldEnableEffects = false
        backGBlur.blendMode = .alpha
        cameraNode.addChild(backGBlur)
        self.addChild(cameraNode)
    }
    
    func addBackgFreezeFrame()
    {
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

            backGBlur.addChild(frozenBackground)

            i += 1

            // Set background first
            frozenBackground.zPosition = -2
            frozenBackground.speed = 0
        }
    }
    
    func addPlatformFreezeFrame() {
        
        //frozenPlatform.removeAllActions()
        
        frozenPlatform = SKSpriteNode(imageNamed: "world1.png")
        let pfTexture = SKTexture(imageNamed: "world1.png")
        
        let movePfAnimation = SKAction.move(by: CGVector(dx: -pfTexture.size().width, dy: 0), duration: 3)
        let shiftPfAnimation = SKAction.move(by: CGVector(dx: pfTexture.size().width, dy: 0), duration: 0)
        
        let pfAnimation = SKAction.sequence([movePfAnimation, shiftPfAnimation])
        let movePfForever = SKAction.repeatForever(pfAnimation)
                
        var i: CGFloat = 0
        
        while i < 2 {
                
            frozenPlatform = SKSpriteNode(imageNamed: "world1.png")
            
            frozenPlatform.position = CGPoint(x: i * pfTexture.size().width, y: -(self.frame.height / 2.5))
            frozenPlatform.name = "platform" + String(format: "%.0f", Double(i))
            frozenPlatform.size = CGSize(width: self.frame.width * 2, height: self.frame.height / 3.5)
    
            frozenPlatform.run(movePfForever, withKey: "platform")
            
            cameraNode.addChild(frozenPlatform)
            
            i += 1

            // Set platform first
            frozenPlatform.zPosition = 0;
            frozenPlatform.speed = 0
        }
    }
    
    func addIdleCharacter() -> Void {
        
        //idleCharacter.removeAllActions()
        idleCharacter = SKSpriteNode(imageNamed: "(b)obby-1.png")
        
        idleCharacter.position = CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.71)
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
        
        cleanUp()
        let menuScene = MenuScene(fileNamed: "MenuScene")
        menuScene?.scaleMode = .aspectFill
        self.view?.presentScene(menuScene!, transition: SKTransition.crossFade(withDuration: 0.5))
    }
    
    func initTitleScreen() {
        
        drawGreenSplat()
        drawMainText()
        drawIconRect()
        drawLikeButton()
        drawTutorialButton()
        drawClickToStart()
    }
    
    func drawGreenSplat() {
        
        greenSplat = SKSpriteNode(imageNamed: "green-splat.png")
        greenSplat.zPosition = 3
        greenSplat.size = CGSize(width: greenSplat.size.width / 1.15, height: greenSplat.size.height / 1.15)
        greenSplat.position = CGPoint(x: self.frame.midX - 20, y: self.frame.maxY / 1.75)
        self.addChild(greenSplat)
    }
    
    func drawMainText() {
        
        mainTitleScreen = SKLabelNode(fontNamed: "MaassslicerItalic")
        mainTitleScreen.position = CGPoint(x: self.frame.midX, y: self.frame.maxY / 2)
        mainTitleScreen.fontColor = .black
        mainTitleScreen.fontSize = 100
        mainTitleScreen.numberOfLines = 1
        mainTitleScreen.text = "Corona Run"
        mainTitleScreen.zPosition = 4
        
        self.addChild(mainTitleScreen)
    }
    
    func drawIconRect() {
        
        iconHolder = SKShapeNode(rect: CGRect(x: -(self.frame.width * 2), y: self.frame.midY / 16, width: self.frame.width * 4, height: 100))
        
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
        
        rateButtonShape = SKShapeNode(circleOfRadius: 50)
        rateButtonShape.fillColor = .white
        rateButtonShape.isAntialiased = true
        rateButtonShape.isUserInteractionEnabled = false
        rateButtonShape.lineWidth = 5
        rateButtonShape.strokeColor = .black
        rateButtonShape.addChild(rateButton)
        
        iconHolder.addChild(rateButtonShape)
        
        rateButtonShape.position = CGPoint(x: -self.size.width / 4, y: 50)
    }
    
    func drawTutorialButton() {
        
        tutorialButton = SKSpriteNode(imageNamed: "question-mark.png")
        tutorialButton.size = CGSize(width: tutorialButton.size.width / 7 , height: tutorialButton.size.height / 7)
        tutorialButton.position = CGPoint(x: 0, y: 0)
        
        tutorialButtonShape = SKShapeNode(circleOfRadius: 50)
        tutorialButtonShape.fillColor = .white
        tutorialButtonShape.isAntialiased = true
        tutorialButtonShape.isUserInteractionEnabled = false
        tutorialButtonShape.lineWidth = 5
        tutorialButtonShape.strokeColor = .black
        tutorialButtonShape.addChild(tutorialButton)
        
        iconHolder.addChild(tutorialButtonShape)
        
        tutorialButtonShape.position = CGPoint(x: 0, y: 50)
    }
    
    func drawSoundButton() {
        
        soundButton = SKSpriteNode(imageNamed: "volume-on.png")
        soundButton.size = CGSize(width: soundButton.size.width / 6 , height: soundButton.size.height / 6)
        soundButton.position = CGPoint(x: 0, y: 0)
        
        soundButtonShape = SKShapeNode(circleOfRadius: 50)
        soundButtonShape.fillColor = .white
        soundButtonShape.isAntialiased = true
        soundButtonShape.isUserInteractionEnabled = false
        soundButtonShape.lineWidth = 5
        soundButtonShape.strokeColor = .black
        soundButtonShape.addChild(soundButton)
        
        iconHolder.addChild(soundButtonShape)
        
        soundButtonShape.position = CGPoint(x: self.size.width / 4, y: 50)
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
        
        let fadeForever = SKAction.repeatForever(fadeSequence)
        
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


