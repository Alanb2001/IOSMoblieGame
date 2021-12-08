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
    var attackers = ["GoldBar","GoldNugget"]
    
    let alienCategory: UInt32 = 0x1 << 1
    let playerCategory: UInt32 = 0x1 << 0
    
    let userDefaults = UserDefaults.standard
    
    var touched : Bool = false
    var location = CGPoint.zero
    
    deinit {
        print("GameScene done")
    }
    
    override func didMove(to view: SKView) {
        setupStarField()
        setupPlayer()
        setupPhisicsWord()
        setupScoreLabel()
        setupCapacityLabel()
        setupAliensAndAsteroids()
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
        playerNode.physicsBody?.contactTestBitMask = alienCategory
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
    
    func setupAliensAndAsteroids() {
        let timeInterval = 0.50
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAliensAndAsteroids), userInfo: nil, repeats: true)
    }
    
    @objc func addAliensAndAsteroids() {
        attackers = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: attackers) as! [String]
        let attacker = SKSpriteNode(imageNamed: attackers[0])
        let attackerPosition = GKRandomDistribution(lowestValue: -200, highestValue: Int(frame.size.width))
        let position = CGFloat(attackerPosition.nextInt())
        attacker.size = CGSize(width: 60, height: 60)
        attacker.position = CGPoint(x: position, y: frame.size.height + attacker.size.height)
        attacker.physicsBody = SKPhysicsBody(circleOfRadius: attacker.size.width/2)
        
        attacker.physicsBody?.categoryBitMask = alienCategory
        attacker.physicsBody?.contactTestBitMask = playerCategory
        attacker.physicsBody?.collisionBitMask = 0
        
        addChild(attacker)
        
        let animationDuration = 4.50
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -attacker.size.height - 300), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        attacker.run(SKAction.sequence(actionArray))
    }
    
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
        let isAlienBody = (bodyWithMinCategoryBitMask.categoryBitMask & alienCategory) != 0
        
        if  isPlayerBody && isAlienBody {
            torpedoDidCollideWithAlien(playerNode: bodyWithMaxCategoryBitMask.node as! SKSpriteNode, alienNode: bodyWithMinCategoryBitMask.node as! SKSpriteNode)
        }
    }
    
    func torpedoDidCollideWithAlien(playerNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        addChild(explosion)
        
        //run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        alienNode.removeFromParent()
        
        run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        capacity += 1
        
        if capacity == 6 * upgradeCapacity
        {
            capacity -= 1
        }
    }
    
    override func didSimulatePhysics() {
        if playerNode.position.x < -250 {
            playerNode.position = CGPoint(x: CGFloat(frame.size.width), y: playerNode.position.y)
        } else if playerNode.position.x > frame.size.width  + 200 {
            playerNode.position = CGPoint(x: -CGFloat(200), y: playerNode.position.y)
        }
    }
}
