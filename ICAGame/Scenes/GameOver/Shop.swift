import SpriteKit
import CoreMotion

class Shop: SKScene {
    
    var starField: SKEmitterNode!
    var moneyNumberLabel: SKLabelNode!
    var newGameButtonNode: SKSpriteNode!
    var menuButtonNode: SKSpriteNode!
    var capacityNumberLabel: SKLabelNode!
    var shakeButtonNode: SKSpriteNode!
    var upgradeCapacityButtonNode: SKSpriteNode!
    var upgradeMoneyButtonNode: SKSpriteNode!
    
    var money: Int = 0
    var capacity: Int = 0
    var upgradeCapacity: Int = 1
    var moneyNeededCapacity: Int = 1
    var upgradeMoney: Int = 1
    var moneyNeededMoney: Int = 1
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    let userDefaults = UserDefaults.standard
    
    deinit {
        print("GameOverScene done")
    }
    
    override func didMove(to view: SKView) {
        setupStarField()
        setupScoreNumberLabel()
        setupCapacityNumberLabel()
        setupCoreMotion()
    }
        
    func setupStarField() {
        starField = self.childNode(withName: "starField") as? SKEmitterNode
        starField.advanceSimulationTime(10)
    }
    
    func setupScoreNumberLabel() {
        moneyNumberLabel = self.childNode(withName: "moneyNumberLabel") as? SKLabelNode
        moneyNumberLabel.text = "\(money)"
    }
    
    func setupCapacityNumberLabel() {
        capacityNumberLabel = self.childNode(withName: "capacityNumberLabel") as? SKLabelNode
        capacityNumberLabel.text = "\(capacity)"
    }
    
    override func update(_ currentTime: TimeInterval) {
        moneyNumberLabel.text = "Money: \(money)"
        capacityNumberLabel.text = "Capacity: \(capacity)"
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let node = nodes(at: location)
        if node.first?.name == "backToGameButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
            gameScene.money = self.money
            gameScene.capacity = self.capacity
            gameScene.upgradeCapacity = self.upgradeCapacity
            gameScene.moneyNeededCapacity = self.moneyNeededCapacity
            gameScene.upgradeMoney = self.upgradeMoney
            gameScene.moneyNeededMoney = self.moneyNeededMoney
            gameScene.scaleMode = .aspectFill
            self.view?.presentScene(gameScene, transition: transition)
        } else if node.first?.name == "menuButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = SKScene(fileNamed: "MenuScene") as! MenuScene
            gameOverScene.scaleMode = .aspectFill
            self.view?.presentScene(gameOverScene, transition: transition)
        } else if node.first?.name == "shakeButton" {
            //shakeButtonNode.position.x += xAcceleration * 50
            capacity -= 1
            money += 5 * upgradeMoney
            if capacity == -1 {
             capacity += 1
                money -= 5 * upgradeMoney
            }
        } else if node.first?.name == "upgradeCapacityButton" {
            if money >= 50 * moneyNeededCapacity {
                money -= 50 * moneyNeededCapacity
                upgradeCapacity += 1
                moneyNeededCapacity += 1
            }
        } else if node.first?.name == "upgradeMoneyButton" {
            if money >= 100 * moneyNeededMoney {
                money -= 100 * moneyNeededMoney
                upgradeMoney += 1
                moneyNeededMoney += 1
            }
        }
    }
}
