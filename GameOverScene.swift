import Foundation
import SpriteKit

class GameOverScene: SKScene{
    let restartLable = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint (x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        let gameOverLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 150
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.47)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        
        restartLable.text = "Restart"
        restartLable.fontSize = 90
        restartLable.fontColor = SKColor.white
        restartLable.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.3)
        restartLable.zPosition = 1
        self.addChild(restartLable)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if restartLable.contains(pointOfTouch){
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
            
        
        }
    }}
    
    
