import SpriteKit

class MenuScene: SKScene {
    
    var starField : SKEmitterNode!
    var newGameButtonNode: SKSpriteNode!
    var gameTitleLabelNode: SKLabelNode!
    
    deinit {
        print("MenuScene done")
    }
    
    override func didMove(to view: SKView) {
        setupStartField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == "newGameButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
            gameScene.scaleMode = .aspectFill
            self.view?.presentScene(gameScene, transition: transition)
    }
}
    
     func setupStartField() {
        starField = self.childNode(withName: "starField") as? SKEmitterNode
        starField.advanceSimulationTime(10)
    }
}
