import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    var starField: SKEmitterNode!
    var playerNode: SKSpriteNode!
    var moneyLabel: SKLabelNode!
    var capacityLabel: SKLabelNode!
    var shopButton: SKSpriteNode!
    
    var money: Int = 0
    var capacity: Int = 0
    var upgradeCapacity: Int = 1
    var moneyNeededCapacity: Int = 1
    var upgradeMoney: Int = 1
    var moneyNeededMoney: Int = 1

    var gameTimer: Timer!
    var attackers = ["meteor","alien"]
    
    let alienCategory: UInt32 = 0x1 << 1
    let playerCategory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
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
        setupShopButton()
        setupAliensAndAsteroids()
        setupCoreMotion()
        movePlayerToLocation()
    }
    
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    func setupPhisicsWord() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        backgroundColor = .blue
    }
    
    func setupStarField() {
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: 0, y: self.frame.maxY)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
    }
    
    func setupPlayer() {
        playerNode = SKSpriteNode(imageNamed: "spaceship")
        playerNode.size = CGSize(width: 80, height: 80)
        playerNode.position = CGPoint(x: frame.size.width / 2, y: playerNode.size.height / 2 + 20)
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2)
        
        playerNode.physicsBody?.categoryBitMask = playerCategory
        playerNode.physicsBody?.contactTestBitMask = alienCategory
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(playerNode)
    }
    
    func setupScoreLabel() {
        moneyLabel = SKLabelNode(text: "Money: 0")
        moneyLabel.position = CGPoint(x: (moneyLabel.frame.width / 2) + 10, y: frame.size.height - 50)
        moneyLabel.zPosition = 5
        moneyLabel.fontSize = 25
        moneyLabel.fontName = "AmericanTypewriter-Bold"
        moneyLabel.color = .white
        addChild(moneyLabel)
    }
    
    func setupCapacityLabel() {
        capacityLabel = SKLabelNode(text: "Capacity: 0")
        capacityLabel.position = CGPoint(x: (capacityLabel.frame.width / 2) + 10, y: frame.size.height - 100)
        capacityLabel.zPosition = 5
        capacityLabel.fontSize = 25
        capacityLabel.fontName = "AmericanTypewriter-Bold"
        capacityLabel.color = .white
        addChild(capacityLabel)
    }
    
    func setupShopButton() {
        shopButton = SKSpriteNode(imageNamed: "shoppingCart")
        shopButton.position = CGPoint(x: (shopButton.frame.width / 2) + 10, y: frame.size.height - 150)
        shopButton.zPosition = 5
        addChild(shopButton)
    }
    
    func setupAliensAndAsteroids() {
        let timeInterval = 0.50
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAliensAndAsteroids), userInfo: nil, repeats: true)
    }
    
    @objc func addAliensAndAsteroids() {
        attackers = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: attackers) as! [String]
        let attacker = SKSpriteNode(imageNamed: attackers[0])
        let attackerPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width))
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
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -attacker.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        attacker.run(SKAction.sequence(actionArray))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = true
        for touch in touches {
            location = touch.location(in: self)
            let nodesArray = nodes(at: location)
            if nodesArray.first == shopButton {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let shopScene = SKScene(fileNamed: "Shop") as! Shop
                shopScene.money = self.money
                shopScene.capacity = self.capacity
                shopScene.upgradeCapacity = self.upgradeCapacity
                shopScene.moneyNeededCapacity = self.moneyNeededCapacity
                shopScene.upgradeMoney = self.upgradeMoney
                shopScene.moneyNeededMoney = self.moneyNeededMoney
                shopScene.self.view?.presentScene(nil)
                self.view?.presentScene(shopScene, transition: transition)
                self.scene?.removeAllActions()
                self.scene?.removeAllChildren()
                self.scene?.removeFromParent()
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
        moneyLabel.text = "Money: \(money)"
        capacityLabel.text = "Capacity: \(capacity)"
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
        playerNode.position.x += xAcceleration * 50
        if playerNode.position.x < -40 {
            playerNode.position = CGPoint(x: CGFloat(frame.size.width), y: playerNode.position.y)
        } else if playerNode.position.x > frame.size.width  + 40 {
            playerNode.position = CGPoint(x: -CGFloat(40), y: playerNode.position.y)
        }
    }
}
