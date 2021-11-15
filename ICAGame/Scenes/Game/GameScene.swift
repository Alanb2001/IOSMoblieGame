import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let difficultManager = DifficultyManager()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let torpedoSoundAction: SKAction = SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false)
    var gameTimer: Timer!
    var attackers = ["meteor","alien"]
    
    let alienCategory: UInt32 = 0x1 << 1
    let torpedoCategory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var livesArray: [SKSpriteNode]!
    
    let userDefaults = UserDefaults.standard
    
    var touched : Bool = false
    var location = CGPoint.zero
    
    override func didMove(to view: SKView) {
        setupLives()
        setupStarField()
        setupPlayer()
        setupPhisicsWord()
        setupScoreLabel()
        setupAliensAndAsteroids()
        setupCoreMotion()
        movePlayerToLocation()
    }
    
    func setupLives() {
        livesArray = [SKSpriteNode]()
        for life in 1...3 {
            let lifeNode = SKSpriteNode(imageNamed: "spaceship")
            lifeNode.size = CGSize(width: 44, height: 44)
            lifeNode.zPosition = 5
            lifeNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - life) * lifeNode.size.width, y: frame.size.height - 50)
            self.addChild(lifeNode)
            livesArray.append(lifeNode)
        }
        
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
        backgroundColor = .black
    }
    
    func setupStarField() {
        starField = SKEmitterNode(fileNamed: "Starfield")
        
        starField.position = CGPoint(x: 0, y: self.frame.maxY)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
    }
    
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "spaceship")
        player.size = CGSize(width: 80, height: 80)
        player.position = CGPoint(x: frame.size.width / 2, y: player.size.height / 2 + 20)
        addChild(player)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: (scoreLabel.frame.width / 2) + 10, y: frame.size.height - 50)
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 25
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.color = .white
        addChild(scoreLabel)
    }
    
    func setupAliensAndAsteroids() {
        let timeInterval = difficultManager.getAlienAparitionInterval()
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
        attacker.physicsBody?.contactTestBitMask = torpedoCategory
        attacker.physicsBody?.collisionBitMask = 0
        
        addChild(attacker)
        
        let animationDuration = difficultManager.getAlienAnimationDutationInterval()
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -attacker.size.height), duration: animationDuration))
        actionArray.append(SKAction.run(alienGotBase))
        actionArray.append(SKAction.removeFromParent())
        
        attacker.run(SKAction.sequence(actionArray))
    }
    
    func alienGotBase() {
        run(SKAction.playSoundFileNamed("looseLife.mp3", waitForCompletion: false))
        if livesArray.count > 0 {
            let lifeNode = livesArray.first
            lifeNode?.removeFromParent()
            livesArray.removeFirst()
        }
        if livesArray.count == 0 {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = SKScene(fileNamed: "GameOver") as! GameOver
            gameScene.score = self.score
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = true
        for touch in touches {
            location = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            location = touch.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
        touched = false
    }
    override func update(_ currentTime: TimeInterval) {
        if (touched) {
            movePlayerToLocation()
        }
    }
    
    func movePlayerToLocation() {
        var dx = location.x - player.position.x
        var dy = location.y - player.position.y
        
        let speed: CGFloat = 0.25
        
        dx = dx * speed
        dy = dy * speed
        player.position = CGPoint(x: player.position.x + dx, y: player.position.y + dy)
    }
    
    func fireTorpedo() {
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        torpedoNode.size = CGSize(width: 30, height: 30)
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width/2)
        
        torpedoNode.physicsBody?.categoryBitMask = torpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(torpedoNode)
        
        let animationDuration = 1.0
        
        var actionArray = [SKAction]()
        actionArray.append(torpedoSoundAction)
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: frame.size.height + torpedoNode.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        torpedoNode.run(SKAction.sequence(actionArray))
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
        let isTorpedoBody = (bodyWithMaxCategoryBitMask.categoryBitMask & torpedoCategory) != 0
        let isAlienBody = (bodyWithMinCategoryBitMask.categoryBitMask & alienCategory) != 0
        
        if  isTorpedoBody && isAlienBody {
            torpedoDidCollideWithAlien(torpedoNode: bodyWithMaxCategoryBitMask.node as! SKSpriteNode, alienNode: bodyWithMinCategoryBitMask.node as! SKSpriteNode)
        }
        
    }
    
    func torpedoDidCollideWithAlien(torpedoNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        addChild(explosion)
        
        run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        score += 5
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        if player.position.x < -40 {
            player.position = CGPoint(x: CGFloat(frame.size.width), y: player.position.y)
        } else if player.position.x > frame.size.width  + 40 {
            player.position = CGPoint(x: -CGFloat(40), y: player.position.y)
        }
    }
}
