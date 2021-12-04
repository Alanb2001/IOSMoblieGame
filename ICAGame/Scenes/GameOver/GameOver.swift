import SpriteKit

class GameOver: SKScene {
    
    var starField: SKEmitterNode!
    var scoreNumberLabel: SKLabelNode!
    var newGameButtonNode: SKSpriteNode!
    var menuButtonNode: SKSpriteNode!
    var capacityNumberLabel: SKLabelNode!
    var shakeButtonNode: SKSpriteNode!
    var upgradeButtonNode: SKSpriteNode!
    
    var money: Int = 0
    var capacity: Int = 0
    var upgradeCapacity: Int = 1
    var moneyNeededCapacity: Int = 1
    
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
        setupUpgradeButton()
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
        newGameButtonNode = self.childNode(withName: "newGameButton") as? SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "newGameButton")
    }
    
    func setupShakeButton() {
        shakeButtonNode = self.childNode(withName: "shakeButton") as? SKSpriteNode
        shakeButtonNode.texture = SKTexture(imageNamed: "newGameButton")
    }
    
    func setupUpgradeButton() {
        upgradeButtonNode = self.childNode(withName: "upgradeButton") as? SKSpriteNode
        upgradeButtonNode.texture = SKTexture(imageNamed: "home")
    }
    
    override func update(_ currentTime: TimeInterval) {
        scoreNumberLabel.text = "Money: \(money)"
        capacityNumberLabel.text = "Capacity: \(capacity)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let node = nodes(at: location)
        if node[0].name == "newGameButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            gameScene.money = self.money
            gameScene.capacity = self.capacity
            gameScene.upgradeCapacity = self.upgradeCapacity
            gameScene.moneyNeededCapacity = self.moneyNeededCapacity
            self.view?.presentScene(gameScene, transition: transition)
        } else if node[0].name == "menuButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = SKScene(fileNamed: "MenuScene") as! MenuScene
            self.view?.presentScene(gameOverScene, transition: transition)
        } else  if node[0].name == "shakeButton" {
            capacity -= 1
            money += 5
            if capacity == -1 {
             capacity += 1
                money -= 5
            }
        } else if node[0].name == "upgradeButton" {
            if money >= 50 * moneyNeededCapacity {
                money -= 50 * moneyNeededCapacity
                upgradeCapacity += 1
                moneyNeededCapacity += 1
            }
        }
    }
    
}
