import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var starField: SKEmitterNode!
    var playerNode: SKSpriteNode!
    var moneyLabel: SKLabelNode!
    var capacityLabel: SKLabelNode!
    var shopButton: SKSpriteNode!
    var moneyNumberLabel: SKLabelNode!
    var capacityNumberLabel: SKLabelNode!
    
    var money: Int = 0
    var capacity: Int = 0
    var upgradeCapacity: Int = 1
    var moneyNeededCapacity: Int = 1
    var upgradeMoney: Int = 1
    var moneyNeededMoney: Int = 1

    var gameTimer: Timer!
    var goldNodes = ["GoldBar","GoldNugget"]
    
    let goldCategory: UInt32 = 0x1 << 1
    let playerCategory: UInt32 = 0x1 << 0
    
    let userDefaults = UserDefaults.standard
    
    var touched : Bool = false
    var location = CGPoint.zero
    
    override func didMove(to view: SKView) {
        setupStarField()
        setupPlayer()
        setupPhisicsWord()
        setupScoreLabel()
        setupCapacityLabel()
        setupGold()
        movePlayerToLocation()
    }

    func setupPhisicsWord() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func setupStarField() {
        starField = self.childNode(withName: "starField") as? SKEmitterNode
        starField.advanceSimulationTime(10)
    }
    
    func setupPlayer() {
        playerNode = self.childNode(withName: "player") as? SKSpriteNode
        
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2)
        
        playerNode.physicsBody?.categoryBitMask = playerCategory
        playerNode.physicsBody?.contactTestBitMask = goldCategory
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func setupScoreLabel() {
        moneyNumberLabel = self.childNode(withName: "moneyNumberLabel") as? SKLabelNode
        moneyNumberLabel.text = "\(money)"
    }
    
    func setupCapacityLabel() {
        capacityNumberLabel = self.childNode(withName: "capacityNumberLabel") as? SKLabelNode
        capacityNumberLabel.text = "\(capacity)"
    }
    
    func setupGold() {
        let timeInterval = 0.50
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addGold), userInfo: nil, repeats: true)
    }
    
    // This function keeps all the information for the gold objects such as position, size and the physics, after that it spawns them into the scene.
    @objc func addGold() {
        goldNodes = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: goldNodes) as! [String]
        let gold = SKSpriteNode(imageNamed: goldNodes[0])
        let goldPosition = GKRandomDistribution(lowestValue: -200, highestValue: 200)
        let position = CGFloat(goldPosition.nextInt())
        gold.size = CGSize(width: 60, height: 60)
        gold.position = CGPoint(x: position, y: frame.size.height + gold.size.height)
        gold.zPosition = -1
        gold.physicsBody = SKPhysicsBody(circleOfRadius: gold.size.width/2)
        
        gold.physicsBody?.categoryBitMask = goldCategory
        gold.physicsBody?.contactTestBitMask = playerCategory
        gold.physicsBody?.collisionBitMask = 0
        
        addChild(gold)
        
        let animationDuration = 4.50
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -gold.size.height - 300), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        gold.run(SKAction.sequence(actionArray))
    }
    
    // This function allows the player to go to the shop if they tap the icon and this also transfers the important data between both scenes.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = true
        for touch in touches {
            location = touch.location(in: self)
            let nodesArray = nodes(at: location)
            if nodesArray.first?.name == "shopButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let shopScene = SKScene(fileNamed: "Shop") as! Shop
                shopScene.money = self.money
                shopScene.capacity = self.capacity
                shopScene.upgradeCapacity = self.upgradeCapacity
                shopScene.moneyNeededCapacity = self.moneyNeededCapacity
                shopScene.upgradeMoney = self.upgradeMoney
                shopScene.moneyNeededMoney = self.moneyNeededMoney
                shopScene.scaleMode = .aspectFill
                run(SKAction.playSoundFileNamed("switch_002.mp3", waitForCompletion: false))
                self.view?.presentScene(shopScene, transition: transition)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            location = touch.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        moneyNumberLabel.text = "Money: \(money)"
        capacityNumberLabel.text = "Capacity: \(capacity)"
        if (touched) {
            movePlayerToLocation()
        }
    }
    
    func movePlayerToLocation() {
        var dx = location.x - playerNode.position.x
        var dy = location.y - playerNode.position.y
        
        let speed: CGFloat = 0.25
        
        dx = dx * speed
        dy = dy * speed
        playerNode.position = CGPoint(x: playerNode.position.x + dx, y: playerNode.position.y + dy)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var bodyWithMaxCategoryBitMask: SKPhysicsBody
        var bodyWithMinCategoryBitMask: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyWithMaxCategoryBitMask = contact.bodyA
            bodyWithMinCategoryBitMask = contact.bodyB
        } else {
            bodyWithMaxCategoryBitMask =  contact.bodyB
            bodyWithMinCategoryBitMask = contact.bodyA
        }
        let isPlayerBody = (bodyWithMaxCategoryBitMask.categoryBitMask & playerCategory) != 0
        let isGoldBody = (bodyWithMinCategoryBitMask.categoryBitMask & goldCategory) != 0
        
        if  isPlayerBody && isGoldBody {
            bowlDidCollideWithGold(playerNode: bodyWithMaxCategoryBitMask.node as! SKSpriteNode, goldNode: bodyWithMinCategoryBitMask.node as! SKSpriteNode)
        }
    }
    
    // This function if the player has collided with some gold and if it has it will be destroyed and your capacity will go up.
    func bowlDidCollideWithGold(playerNode: SKSpriteNode, goldNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = goldNode.position
        explosion.zPosition = -1
        addChild(explosion)
        
        run(SKAction.playSoundFileNamed("impactMining_002.mp3", waitForCompletion: false))
        
        goldNode.removeFromParent()
        
        run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        capacity += 1
        
        if capacity == 6 * upgradeCapacity
        {
            capacity -= 1
        }
    }
}
