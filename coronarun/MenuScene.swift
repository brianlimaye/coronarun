//
//  MenuScene.swift
//  coronarun
//
//  Created by Brian Limaye on 6/2/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene
{
    var levelScreen: SKSpriteNode = SKSpriteNode()
    var worldDisplayShape: SKShapeNode = SKShapeNode()
    var worldDisplay: SKLabelNode = SKLabelNode()
    var futureLevelDisplay: SKLabelNode = SKLabelNode()
    var levelBox: SKShapeNode = SKShapeNode()
    var levelButtons = [SKShapeNode]()
    var levelNumerals = [SKLabelNode]()
    
    
    override func didMove(to view: SKView) {
        
        self.addChild(cameraNode)
        drawWorldDisplay()
        drawLevelButtons()
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
        oneNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        
        let levelOne = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelOne.fillColor = .black
        levelOne.strokeColor = .white
        levelOne.lineWidth = 10
        levelOne.addChild(oneNumeral)
        levelOne.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY + 150)
        
        //Level Two Button
        let twoNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        twoNumeral.fontColor = .white
        twoNumeral.fontSize = 100
        twoNumeral.text = "2"
        twoNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        
        let levelTwo = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelTwo.fillColor = .black
        levelTwo.strokeColor = .white
        levelTwo.lineWidth = 10
        levelTwo.addChild(twoNumeral)
        levelTwo.position = CGPoint(x: self.frame.midX - 50, y: self.frame.midY + 150)
        
        //Level Three Button
        let threeNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        threeNumeral.fontColor = .white
        threeNumeral.fontSize = 100
        threeNumeral.text = "3"
        threeNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        
        let levelThree = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelThree.fillColor = .black
        levelThree.strokeColor = .white
        levelThree.lineWidth = 10
        levelThree.addChild(threeNumeral)
        levelThree.position = CGPoint(x: self.frame.midX + 100, y: self.frame.midY + 150)
        
        //Level Four Button
        
        let fourNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        fourNumeral.fontColor = .white
        fourNumeral.fontSize = 100
        fourNumeral.text = "4"
        fourNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        
        let levelFour = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelFour.fillColor = .black
        levelFour.strokeColor = .white
        levelFour.lineWidth = 10
        levelFour.addChild(fourNumeral)
        levelFour.position = CGPoint(x: self.frame.midX - 200, y: self.frame.midY)
        
        //Level Five Button
        
        let fiveNumeral = SKLabelNode(fontNamed: "KeyVirtueRegular")
        fiveNumeral.fontColor = .white
        fiveNumeral.fontSize = 100
        fiveNumeral.text = "5"
        fiveNumeral.position = CGPoint(x: (self.frame.height / 24), y: (self.frame.height / 48))
        
        let levelFive = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.frame.height / 12, height: self.frame.height / 12), cornerRadius: 25)
        levelFive.fillColor = .black
        levelFive.strokeColor = .white
        levelFive.lineWidth = 10
        levelFive.addChild(fiveNumeral)
        levelFive.position = CGPoint(x: self.frame.midX - 50, y: self.frame.midY)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view?.presentScene(gameScene)
    }
}
