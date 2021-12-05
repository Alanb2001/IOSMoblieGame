import SpriteKit

class Shop: SKScene {
    
    var starField: SKEmitterNode!
    var scoreNumberLabel: SKLabelNode!
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
    
    let userDefaults = UserDefaults.standard
    
    deinit {
        print("GameOverScene done")
    }
    
    override func didMove(to view: SKView) {
        setupStarField()
        setupScoreNumberLabel()
        setupCapacityNumberLabel()
        setupNewGameButton()
        setupMenuButtonNode()
        setupShakeButton()
        setupUpgradeCapacityButton()
        setupUpgradeMoneyButton()
    }
        
    func setupMenuButtonNode() {
        menuButtonNode = childNode(withName: "menuButton") as? SKSpriteNode
        menuButtonNode.texture = SKTexture(imageNamed: "home")
    }
    
    func setupStarField() {
        starField = self.childNode(withName: "starField") as? SKEmitterNode
        starField.advanceSimulationTime(10)
    }
    
    func setupScoreNumberLabel() {
        scoreNumberLabel = self.childNode(withName: "scoreNumberLabel") as? SKLabelNode
        scoreNumberLabel.text = "\(money)"
    }
    
    func setupCapacityNumberLabel() {
        capacityNumberLabel = self.childNode(withName: "capacityNumberLabel") as? SKLabelNode
        capacityNumberLabel.text = "\(capacity)"
    }
    
    func setupNewGameButton() {
        newGameButtonNode = self.childNode(withName: "backToGameButton") as? SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "gamepad")
    }
    
    func setupShakeButton() {
        shakeButtonNode = self.childNode(withName: "shakeButton") as? SKSpriteNode
        shakeButtonNode.texture = SKTexture(imageNamed: "deviceTilt_right")
    }
    
    func setupUpgradeCapacityButton() {
        upgradeCapacityButtonNode = self.childNode(withName: "upgradeCapacityButton") as? SKSpriteNode
        upgradeCapacityButtonNode.texture = SKTexture(imageNamed: "shoppingBasket")
    }
    
    func setupUpgradeMoneyButton() {
        upgradeMoneyButtonNode = self.childNode(withName: "upgradeMoneyButton") as? SKSpriteNode
        upgradeMoneyButtonNode.texture = SKTexture(imageNamed: "coin")
    }
    
    override func update(_ currentTime: TimeInterval) {
        scoreNumberLabel.text = "Money: \(money)"
        capacityNumberLabel.text = "Capacity: \(capacity)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let node = nodes(at: location)
        if node[0].name == "backToGameButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            gameScene.money = self.money
            gameScene.capacity = self.capacity
            gameScene.upgradeCapacity = self.upgradeCapacity
            gameScene.moneyNeededCapacity = self.moneyNeededCapacity
            gameScene.upgradeMoney = self.upgradeMoney
            gameScene.moneyNeededMoney = self.moneyNeededMoney
            self.view?.presentScene(gameScene, transition: transition)
        } else if node[0].name == "menuButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = SKScene(fileNamed: "MenuScene") as! MenuScene
            self.view?.presentScene(gameOverScene, transition: transition)
        } else if node[0].name == "shakeButton" {
            capacity -= 1
            money += 5 * upgradeMoney
            if capacity == -1 {
             capacity += 1
                money -= 5 * upgradeMoney
            }
        } else if node[0].name == "upgradeCapacityButton" {
            if money >= 50 * moneyNeededCapacity {
                money -= 50 * moneyNeededCapacity
                upgradeCapacity += 1
                moneyNeededCapacity += 1
            }
        } else if node[0].name == "upgradeMoneyButton" {
            if money >= 100 * moneyNeededMoney {
                money -= 100 * moneyNeededMoney
                upgradeMoney += 1
                moneyNeededMoney += 1
            }
        }
    }
}
