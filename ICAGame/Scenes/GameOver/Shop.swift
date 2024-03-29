import SpriteKit
import CoreMotion

class Shop: SKScene {
    
    var starField: SKEmitterNode!
    var moneyNumberLabel: SKLabelNode!
    var capacityNumberLabel: SKLabelNode!
    var cashNeededCapacityLabel: SKLabelNode!
    var cashNeededMoneyLabel: SKLabelNode!
    
    var money: Int = 0
    var capacity: Int = 0
    var upgradeCapacity: Int = 1
    var moneyNeededCapacity: Int = 1
    var upgradeMoney: Int = 1
    var moneyNeededMoney: Int = 1
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    let userDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        setupStarField()
        setupScoreNumberLabel()
        setupCapacityNumberLabel()
        setupCashNeededCapacityLabel()
        setupCashNeededMoneyLabel()
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
    
    func setupCashNeededCapacityLabel() {
        cashNeededCapacityLabel = self.childNode(withName: "cashNeededCapacityLabel") as? SKLabelNode
        cashNeededCapacityLabel.text = "\(moneyNeededCapacity)"
    }
    
    func setupCashNeededMoneyLabel() {
        cashNeededMoneyLabel = self.childNode(withName: "cashNeededMoneyLabel") as? SKLabelNode
        cashNeededMoneyLabel.text = "\(moneyNeededMoney)"
    }
    
    override func update(_ currentTime: TimeInterval) {
        moneyNumberLabel.text = "Money: \(money)"
        capacityNumberLabel.text = "Capacity: \(capacity)"
        cashNeededCapacityLabel.text = "Needed: \(50 * moneyNeededCapacity)"
        cashNeededMoneyLabel.text = "Needed: \(100 * moneyNeededMoney)"
    }
    
    // This function sets up the accelerometer and its data so that it can be used for the game.
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    // This function makes it so that when you tilt your phone left or right a certain amount you will get money from the gold collected using the accelerometer.
    override func didSimulatePhysics() {
        run(SKAction.wait(forDuration: 3)) {
            if self.xAcceleration >= 0.3 {
                self.capacity -= 1
                self.money += 5 * self.upgradeMoney
                if self.capacity == -1 {
                    self.capacity += 1
                    self.money -= 5 * self.upgradeMoney
                }
            } else if self.xAcceleration <=  -0.3{
                    self.capacity -= 1
                    self.money += 5 * self.upgradeMoney
                    if self.capacity == -1 {
                        self.capacity += 1
                        self.money -= 5 * self.upgradeMoney
                }
            }
        }
    }
    
    // This function allows you to back and forth between the game scene and the menu scene, as well as allowing you to get upgrades.
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
            run(SKAction.playSoundFileNamed("switch_002.mp3", waitForCompletion: false))
            self.view?.presentScene(gameScene, transition: transition)
        } else if node.first?.name == "menuButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = SKScene(fileNamed: "MenuScene") as! MenuScene
            gameOverScene.scaleMode = .aspectFill
            run(SKAction.playSoundFileNamed("switch_002.mp3", waitForCompletion: false))
            self.view?.presentScene(gameOverScene, transition: transition)
        } else if node.first?.name == "upgradeCapacityButton" {
            run(SKAction.playSoundFileNamed("switch_002.mp3", waitForCompletion: false))
            if money >= 50 * moneyNeededCapacity {
                money -= 50 * moneyNeededCapacity
                upgradeCapacity += 1
                moneyNeededCapacity += 1
            }
        } else if node.first?.name == "upgradeMoneyButton" {
            run(SKAction.playSoundFileNamed("switch_002.mp3", waitForCompletion: false))
            if money >= 100 * moneyNeededMoney {
                money -= 100 * moneyNeededMoney
                upgradeMoney += 1
                moneyNeededMoney += 1
            }
        }
    }
}
