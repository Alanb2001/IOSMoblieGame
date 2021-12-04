import SpriteKit

class MenuScene: SKScene {
    
    var starField : SKEmitterNode!
    
    var newGameButtonNode: SKSpriteNode!
    var gameTitleLabelNode: SKLabelNode!
    
    let newGameButtonName = "newGameButton"
    
    deinit {
        print("MenuScene done")
    }
    
    override func didMove(to view: SKView) {
        setupGameTitleLabel()
        setupStartField()
        setupNewGameButtonNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == newGameButtonName {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size) 
            self.view?.presentScene(gameScene, transition: transition)
    }
}

     func setupGameTitleLabel() {
        gameTitleLabelNode = childNode(withName: "gameTitleLabel") as? SKLabelNode
        let yPosition = gameTitleLabelNode.position.y
        gameTitleLabelNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
     func setupNewGameButtonNode() {
        newGameButtonNode = self.childNode(withName: newGameButtonName) as? SKSpriteNode
        let yPosition = newGameButtonNode.position.y
        newGameButtonNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
     func setupStartField() {
        starField = self.childNode(withName: "starField") as? SKEmitterNode
        starField.advanceSimulationTime(10)
    }
}
