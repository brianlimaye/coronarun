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
    var confettiView = SAConfettiView()
    var worldDisplayShape: SKShapeNode = SKShapeNode()
    var worldDisplay: SKLabelNode = SKLabelNode()
    var futureLevelDisplay: SKLabelNode = SKLabelNode()
    var levelBox: SKShapeNode = SKShapeNode()
    
    var levelOne: SKShapeNode = SKShapeNode()
    var levelTwo: SKShapeNode = SKShapeNode()
    var levelThree: SKShapeNode = SKShapeNode()
    var levelFour: SKShapeNode = SKShapeNode()
    var levelFive: SKShapeNode = SKShapeNode()
    var oneNumeral: SKLabelNode = SKLabelNode()
    var twoNumeral: SKLabelNode = SKLabelNode()
    var threeNumeral: SKLabelNode = SKLabelNode()
    var fourNumeral: SKLabelNode = SKLabelNode()
    var fiveNumeral: SKLabelNode = SKLabelNode()
    
    var levelTwoLock: SKSpriteNode = SKSpriteNode()
    var levelThreeLock: SKSpriteNode = SKSpriteNode()
    var levelFourLock: SKSpriteNode = SKSpriteNode()
    var levelFiveLock: SKSpriteNode = SKSpriteNode()
        
    override func didMove(to view: SKView) {
        
        //attemptEndAnimation()
        makeCharVisible()
        showBackground()
        drawWorldDisplay()
        drawLevelButtons()
        removeLocks()
    }
    
    func removeLocks() {
        
        for i in 0 ... levelData.maxLevel - 1 {
            
            if(!levelData.hasLocks[i])
            {
                updateLockDisplay(level: String(i + 1))
            }
        }
    }
    
    func updateLockDisplay(level: String) {
        
        switch(level)
        {
            case "2":
                if(levelTwoLock.parent != nil)
                {
                    levelTwoLock.removeFromParent()
                    levelTwo.name = "level-two"
                    twoNumeral.name = "2"
                }
            case "3":
                if(levelThreeLock.parent != nil)
                {
                    levelThreeLock.removeFromParent()
                    levelThree.name = "level-three"
                    threeNumeral.name = "3"
                }
            case "4":
                if(levelFourLock.parent != nil)
                {
                    levelFourLock.removeFromParent()
                    levelFour.name = "level-four"
                    fourNumeral.name = "4"
                }
            case "5":
                if(levelFiveLock.parent != nil)
                {
                    levelFiveLock.removeFromParent()
                    levelFive.name = "level-five"
                    fiveNumeral.name = "5"
                }
            default:
                print("other")
        }
    }
    
    func attemptEndAnimation() {
        
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
    
    func showBackground() {
        
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
        oneNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        oneNumeral.fontColor = .white
        oneNumeral.fontSize = 100
        oneNumeral.text = "1"
        oneNumeral.name = "1"
        oneNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        oneNumeral.isUserInteractionEnabled = false

        
        levelOne = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelOne.name = "level-one"
        levelOne.fillColor = .black
        levelOne.strokeColor = .white
        levelOne.lineWidth = 10
        levelOne.addChild(oneNumeral)
        levelOne.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY + 150)
        levelOne.isUserInteractionEnabled = false
        
        //Level Two Button
        twoNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        twoNumeral.fontColor = .white
        twoNumeral.fontSize = 100
        twoNumeral.text = "2"
        twoNumeral.name = "locked"
        twoNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        twoNumeral.isUserInteractionEnabled = false
        
        levelTwo = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelTwo.name = "locked"
        levelTwo.fillColor = .black
        levelTwo.strokeColor = .white
        levelTwo.lineWidth = 10
        levelTwo.addChild(twoNumeral)
        levelTwo.position = CGPoint(x: self.frame.midX - 50, y: self.frame.midY + 150)
        levelTwo.isUserInteractionEnabled = false
        
        levelTwoLock = SKSpriteNode(imageNamed: "lock.png")
        levelTwoLock.size = CGSize(width: levelTwoLock.size.width / 8, height: levelTwoLock.size.height / 8)
        levelTwo.addChild(levelTwoLock)
        levelTwoLock.position = CGPoint(x: levelTwoLock.frame.width / 2.25, y: levelTwoLock.frame.height / 2.25)
        levelTwoLock.zPosition = 1
        
        //Level Three Button
        threeNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        threeNumeral.fontColor = .white
        threeNumeral.fontSize = 100
        threeNumeral.text = "3"
        threeNumeral.name = "locked"
        threeNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        threeNumeral.isUserInteractionEnabled = false

        
        levelThree = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelThree.name = "locked"
        levelThree.fillColor = .black
        levelThree.strokeColor = .white
        levelThree.lineWidth = 10
        levelThree.addChild(threeNumeral)
        levelThree.position = CGPoint(x: self.frame.midX + 100, y: self.frame.midY + 150)
        levelThree.isUserInteractionEnabled = false
        
        levelThreeLock = SKSpriteNode(imageNamed: "lock.png")
        levelThreeLock.size = CGSize(width: levelThreeLock.size.width / 8, height: levelThreeLock.size.height / 8)
        levelThree.addChild(levelThreeLock)
        levelThreeLock.position = CGPoint(x: levelThreeLock.frame.width / 2.25, y: levelThreeLock.frame.height / 2.25)
        levelThreeLock.zPosition = 1
        
        //Level Four Button
        
        fourNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        fourNumeral.fontColor = .white
        fourNumeral.fontSize = 100
        fourNumeral.text = "4"
        fourNumeral.name = "locked"
        fourNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        fourNumeral.isUserInteractionEnabled = false

        
        levelFour = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelFour.name = "locked"
        levelFour.fillColor = .black
        levelFour.strokeColor = .white
        levelFour.lineWidth = 10
        levelFour.addChild(fourNumeral)
        levelFour.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY)
        levelFour.isUserInteractionEnabled = false
        
        levelFourLock = SKSpriteNode(imageNamed: "lock.png")
        levelFourLock.size = CGSize(width: levelFourLock.size.width / 8, height: levelFourLock.size.height / 8)
        levelFour.addChild(levelFourLock)
        levelFourLock.position = CGPoint(x: levelFourLock.frame.width / 2.25, y: levelFourLock.frame.height / 2.25)
        levelFourLock.zPosition = 1
        
        //Level Five Button
        
        fiveNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        fiveNumeral.fontColor = .white
        fiveNumeral.fontSize = 100
        fiveNumeral.text = "5"
        fiveNumeral.name = "locked"
        fiveNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        fiveNumeral.isUserInteractionEnabled = false

        
        levelFive = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelFive.name = "locked"
        levelFive.fillColor = .black
        levelFive.strokeColor = .white
        levelFive.lineWidth = 10
        levelFive.addChild(fiveNumeral)
        levelFive.position = CGPoint(x: self.frame.midX - 50, y: self.frame.midY)
        levelFive.isUserInteractionEnabled = false
        
        levelFiveLock = SKSpriteNode(imageNamed: "lock.png")
        levelFiveLock.size = CGSize(width: levelFiveLock.size.width / 8, height: levelFiveLock.size.height / 8)
        levelFive.addChild(levelFiveLock)
        levelFiveLock.position = CGPoint(x: levelFiveLock.frame.width / 2.25, y: levelFiveLock.frame.height / 2.25)
        levelFiveLock.zPosition = 1
        
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
                levelData.levelSelected = 1
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-two") || (node?.name == "2"))
            {
                confettiView.removeFromSuperview()
                levelData.levelSelected = 2
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-three") || (node?.name == "3"))
            {
                confettiView.removeFromSuperview()
                levelData.levelSelected = 3
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-four") || (node?.name == "4"))
            {
                confettiView.removeFromSuperview()
                levelData.levelSelected = 4
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
            else if((node?.name == "level-five") || (node?.name == "5"))
            {
                confettiView.removeFromSuperview()
                levelData.levelSelected = 5
                
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
        }
    }
}
