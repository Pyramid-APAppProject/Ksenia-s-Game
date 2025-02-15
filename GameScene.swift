# Ksenia-s-Game

import SpriteKit
import GameplayKit
 
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let player = SKSpriteNode(imageNamed: "perry")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
    }

  

    func random() -> CGFloat {
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    
    
    let gameArea: CGRect
    override init(size: CGSize) {
        
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        
        super.init(size: size)
    
    }
    
    
   
    
    func spawnEnemy(){
           let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
           let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
           
           let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
           let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
           
           let enemy = SKSpriteNode(imageNamed: "enemy")
           enemy.name = "Enemy"
           enemy.setScale(0.25)
           enemy.position = startPoint
        enemy.zPosition = 2
           enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
           enemy.physicsBody!.affectedByGravity = false
           enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
           enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
           enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
           
           self.addChild(enemy)
           
           let moveEnemy = SKAction.move(to: endPoint, duration: 5)
           let deleteEnemy = SKAction.removeFromParent()
           let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
           if currentGameState == gameState.inGame{
           enemy.run(enemySequence)
        }
           
           let dx = endPoint.x - startPoint.x
           let dy = endPoint.y - startPoint.y
           
           let amoutToRotate = atan2(dy, dx)
           enemy.zRotation = amoutToRotate
       }
    
    
    
    
    
    func startNewLevel(){
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
    }
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
    let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint (x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
       
        player.setScale(0.2)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height/5)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.47)
        self.addChild(tapToStartLabel)
        
    }
    
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var bodyOne = SKPhysicsBody()
        var bodyTwo = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            bodyOne = contact.bodyA
            bodyTwo = contact.bodyB
            
        }
        else{
            bodyOne = contact.bodyB
            bodyTwo = contact.bodyA
            
    }
        if bodyOne.categoryBitMask == PhysicsCategories.Player && bodyTwo.categoryBitMask == PhysicsCategories.Enemy{
            //if the player has hit the enemy
            if bodyOne.node != nil {
            spawnExplosion(spawnPosition: bodyOne.node!.position)
            }
            
            if bodyTwo.node != nil {
            spawnExplosion(spawnPosition: bodyTwo.node!.position)
            }
            bodyOne.node?.removeFromParent()
            bodyTwo.node?.removeFromParent()
            
            runGameOver()
        }
        
         if bodyOne.categoryBitMask == PhysicsCategories.Bullet && bodyTwo.categoryBitMask == PhysicsCategories.Enemy
         {
                 //if the bullet has hit the enemy
           if bodyTwo.node != nil {
            spawnExplosion(spawnPosition: bodyTwo.node!.position)
              }
         
                 bodyOne.node?.removeFromParent()
                 bodyTwo.node?.removeFromParent()
                 
    }
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
    
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    
    
    
    override func touchesBegan (_ touches: Set<UITouch>, with event: UIEvent?){
        if currentGameState == gameState.preGame{
            startGame()
        }
        
        else if currentGameState == gameState.inGame{
            fireBullet()
                    
                }
                
    }
    
     
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       for touch: AnyObject in touches{
    let pointOfTouch = touch.location(in: self)
    let previousPointOfTouch = touch.previousLocation(in: self)
    let amountDragged = pointOfTouch.x - previousPointOfTouch.x
        if currentGameState == gameState.inGame {
            player.position.x += amountDragged}
    
    if player.position.x > gameArea.maxX - player.size.width/2{
        player.position.x = gameArea.maxX - player.size.width/2
    }
    if player.position.x < gameArea.minX + player.size.width/2{
        player.position.x = gameArea.minX + player.size.width/2
        
         }}}
    
    func fireBullet() {
      let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(0.15)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
       bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
            }
    
    
    func runGameOver () {
        currentGameState = gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes (withName: "Bullet") {
        bullet, stop in
        bullet.removeAllActions()
        }
        self.enumerateChildNodes (withName: "Enemy") {
        enemy, stop in
        enemy.removeAllActions()
    }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    enum gameState {
        case preGame  //before game starts
        case inGame //during the game
        case afterGame //after the game ends
    
    }
    var currentGameState = gameState.preGame
    func changeScene (){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    func startGame(){
        
        currentGameState = gameState.inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteAction)
        
        let movePerryOntoScreen = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([movePerryOntoScreen, startLevelAction])
        player.run(startGameSequence)
        
        
        
        
    }
}
    
    
       
            
