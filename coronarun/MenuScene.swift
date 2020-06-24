//
//  MenuScene.swift
//  coronarun
//
//  Created by Brian Limaye on 6/2/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import Foundation
import SpriteKit
import SAConfettiView

class MenuScene: SKScene
{
    var levelScreen: SKSpriteNode = SKSpriteNode()
    var confettiView = SAConfettiView()
    var worldDisplayShape: SKShapeNode = SKShapeNode()
    var worldDisplay: SKLabelNode = SKLabelNode()
    var futureLevelDisplay: SKLabelNode = SKLabelNode()
    var levelBox: SKShapeNode = SKShapeNode()
    var levelButtons = [SKShapeNode]()
    var levelNumerals = [SKLabelNode]()
    
    override func didMove(to view: SKView) {
        
        completionAnimation()
        makeCharVisible()
        blurBackground()
        drawWorldDisplay()
        drawLevelButtons()
    }
    
    func completionAnimation() {
        
        if(levelData.hasMastered)
        {
            confettiView = SAConfettiView(frame: (self.view?.bounds)!)
            confettiView.type = .Diamond
            
            view?.addSubview(confettiView)
            confettiView.startConfetti()
        }
    }
    
    func makeCharVisible() {
        
        for child in cameraNode.children {
            
            if(child.name == "character")
            {
                child.isHidden = false
            }
        }
    }
    
    func blurBackground() {
        
        backGBlur.shouldEnableEffects = true
        self.addChild(cameraNode)
    }
    
    func drawWorldDisplay() {
        
        worldDisplayShape = SKShapeNode(rect: CGRect(x: -self.frame.width, y: self.frame.midY + 400, width: (2 * frame.size.width), height: 300))

        worldDisplayShape.fillColor = .clear
        worldDisplayShape.strokeColor = .white
        worldDisplayShape.isAntialiased = true
        worldDisplayShape.lineWidth = 10
        worldDisplayShape.addChild(worldDisplay)
        worldDisplayShape.zPosition = 2
        
        worldDisplay = SKLabelNode(fontNamed: "CarbonBl-Regular")
        worldDisplay.position = CGPoint(x: 0, y: 420)
        worldDisplay.fontColor = .white
        worldDisplay.text = "World 1"
        worldDisplay.fontSize = 100
        
        //worldDisplay.zPosition = 1
        
        self.addChild(worldDisplayShape)
        self.addChild(worldDisplay)
    }
    
    func drawLevelButtons() {
        
        //Level One Button
        let oneNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        oneNumeral.fontColor = .white
        oneNumeral.fontSize = 100
        oneNumeral.text = "1"
        oneNumeral.name = "1"
        oneNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        oneNumeral.isUserInteractionEnabled = false

        
        let levelOne = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelOne.name = "level-one"
        levelOne.fillColor = .black
        levelOne.strokeColor = .white
        levelOne.lineWidth = 10
        levelOne.addChild(oneNumeral)
        levelOne.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY + 150)
        levelOne.isUserInteractionEnabled = false
        
        //Level Two Button
        let twoNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        twoNumeral.fontColor = .white
        twoNumeral.fontSize = 100
        twoNumeral.text = "2"
        twoNumeral.name = "2"
        twoNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        twoNumeral.isUserInteractionEnabled = false

        
        let levelTwo = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelTwo.name = "level-two"
        levelTwo.fillColor = .black
        levelTwo.strokeColor = .white
        levelTwo.lineWidth = 10
        levelTwo.addChild(twoNumeral)
        levelTwo.position = CGPoint(x: self.frame.midX - 50, y: self.frame.midY + 150)
        levelTwo.isUserInteractionEnabled = false
        
        //Level Three Button
        let threeNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        threeNumeral.fontColor = .white
        threeNumeral.fontSize = 100
        threeNumeral.text = "3"
        threeNumeral.name = "3"
        threeNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        threeNumeral.isUserInteractionEnabled = false

        
        let levelThree = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelThree.name = "level-three"
        levelThree.fillColor = .black
        levelThree.strokeColor = .white
        levelThree.lineWidth = 10
        levelThree.addChild(threeNumeral)
        levelThree.position = CGPoint(x: self.frame.midX + 100, y: self.frame.midY + 150)
        levelThree.isUserInteractionEnabled = false
        
        //Level Four Button
        
        let fourNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        fourNumeral.fontColor = .white
        fourNumeral.fontSize = 100
        fourNumeral.text = "4"
        fourNumeral.name = "4"
        fourNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        fourNumeral.isUserInteractionEnabled = false

        
        let levelFour = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelFour.name = "level-four"
        levelFour.fillColor = .black
        levelFour.strokeColor = .white
        levelFour.lineWidth = 10
        levelFour.addChild(fourNumeral)
        levelFour.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY)
        levelFour.isUserInteractionEnabled = false
        
        //Level Five Button
        
        let fiveNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        fiveNumeral.fontColor = .white
        fiveNumeral.fontSize = 100
        fiveNumeral.text = "5"
        fiveNumeral.name = "5"
        fiveNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        fiveNumeral.isUserInteractionEnabled = false

        
        let levelFive = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelFive.name = "level-five"
        levelFive.fillColor = .black
        levelFive.strokeColor = .white
        levelFive.lineWidth = 10
        levelFive.addChild(fiveNumeral)
        levelFive.position = CGPoint(x: self.frame.midX - 50, y: self.frame.midY)
        levelFive.isUserInteractionEnabled = false
        
        futureLevelDisplay = SKLabelNode(fontNamed: "DKHand-Regular")
        futureLevelDisplay.fontColor = .white
        futureLevelDisplay.fontSize = 64
        futureLevelDisplay.text = "New Levels Coming Soon..."
        futureLevelDisplay.position = CGPoint(x: 0, y: self.frame.midY - 150)
        
        
        
        levelBox = SKShapeNode(rect: CGRect(x: -self.frame.width / 3, y: self.frame.midY - 400, width: ((2 * self.frame.width) / 3), height: 700))
        levelBox.fillColor = .clear
        levelBox.strokeTexture = SKTexture(imageNamed: "seamless-background.png")
        levelBox.lineWidth = 25
        levelBox.isAntialiased = true
        levelBox.addChild(levelOne)
        levelBox.addChild(levelTwo)
        levelBox.addChild(levelThree)
        levelBox.addChild(levelFour)
        levelBox.addChild(levelFive)
        levelBox.addChild(futureLevelDisplay)
        
        self.addChild(levelBox)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if((node?.name == "level-one") || (node?.name == "1"))
            {
                confettiView.removeFromSuperview()
                print("level-one pressed")
                levelData.levelSelected = 1
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-two") || (node?.name == "2"))
            {
                confettiView.removeFromSuperview()
                print("level-two pressed")
                levelData.levelSelected = 2
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-three") || (node?.name == "3"))
            {
                confettiView.removeFromSuperview()
                print("level-three pressed")
                levelData.levelSelected = 3
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-four") || (node?.name == "4"))
            {
                confettiView.removeFromSuperview()
                print("level-four pressed")
                levelData.levelSelected = 4
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-five") || (node?.name == "5"))
            {
                confettiView.removeFromSuperview()
                print("level-five pressed")
                levelData.levelSelected = 5
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
        }
    }
}
