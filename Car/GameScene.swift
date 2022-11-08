import SpriteKit
import GameplayKit

extension ClosedRange where Element: Hashable {
    func random(without excluded:[Element]) -> Element {
        let valid = Set(self).subtracting(Set(excluded))
        let random = Int(arc4random_uniform(UInt32(valid.count)))
        return Array(valid)[random]
    }
}

class GameScene: SKScene {
    var car:SKSpriteNode!
    let width = 35
    let height = 25
    var Points:[CGPoint] = []
    var arrayPoint:[[Int]] = [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,2,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]
    var generator = (0,0)
    
    var timer: Timer!
    var x = 18
    var dx = 0
    var left = Key()
    var right = Key()
    
    var game_over = false
    
    override func didMove(to view: SKView) {
        refresh_generator(force: false)
        generate_map()
        create_map()
        create_car()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func refresh_generator(force: Bool) {
        if generator.1 == 0 || force{
            generator = ((-1...1).random(without: [generator.0]), Int.random(in: 1..<15))
        }
    }
    
    func generate_map(){
        while arrayPoint.count <= height {
            let row = generateNextRow(prevRow: arrayPoint[0])
            arrayPoint.insert(row, at: 0)
        }
    }
    
    func generateNextRow(prevRow: [Int]) -> [Int]{
        refresh_generator(force: false)
        let prev = prevRow.firstIndex(of: 0)!
        if (prev < 1 && generator.0 == -1) || (prev >= 30 && generator.0 == 1){
            refresh_generator(force: true)
        }
        
        var row = Array(repeating: 1, count: 35)
        for i in 0...4{
            row[prev + i + generator.0] = 0
        }
        generator.1 -= 1
        return row
    }
    
    func create_map(){
        var x:CGFloat = -self.size.width/2 + self.size.width/CGFloat(width)/2
        var y:CGFloat = self.size.height/2 - self.size.width/CGFloat(height)/2
        for i in 0...arrayPoint.count - 1{
            x = -self.size.width/2 + self.size.width/CGFloat(arrayPoint[0].count)/2
            if i==0{
                y = self.size.height/2 - self.size.width/CGFloat(arrayPoint[0].count)/2
            }else{
                y-=self.size.width/CGFloat(arrayPoint[0].count)
            }
            for j in 0...arrayPoint[0].count - 1{
                let ground = SKSpriteNode(color: .white, size: CGSize(width: self.size.width/CGFloat(arrayPoint[0].count), height: self.size.width/CGFloat(arrayPoint[0].count)))
                
                if arrayPoint[i][j]==0{
                    ground.name = "0"
                    ground.color = .white
                }else if arrayPoint[i][j]==1{
                    ground.name = "1"
                    ground.color = .black
                }
                
                ground.position = CGPoint(x: x, y: y)
                x+=self.size.width/CGFloat(arrayPoint[0].count)
                addChild(ground)
                Points.append(ground.position)
            }
        }
    }
    
    func create_car(){
        car = SKSpriteNode(texture: SKTexture(imageNamed: "car"), size: CGSize(width: self.size.width/CGFloat(arrayPoint[0].count), height: self.size.width/CGFloat(arrayPoint[0].count)))
        car.name = "car"
        car.position = Points[Points.count - x]
        addChild(car)
    }
    
    fileprivate func keysUpdateOnTimerTik() {
        left.tik()
        right.tik()
    }
    
    fileprivate func doMove() {
        if left.status == 1 || left.status == 2 || left.status == 3{
            dx += 1
        }
        if right.status == 1 || right.status == 2 || right.status == 3{
            dx -= 1
        }
    }
    
    func check_collision(){
        for child in children{
            if child.name == "1" && child.position == Points[Points.count - x]{
                game_over = true
            }
        }
    }
    
    @objc func fireTimer() {
        doMove()
        x += dx
        
        check_collision()
        if !game_over{
            for child in children{
                if child.name == "0" || child.name == "1"{
                    child.removeFromParent()
                }
            }
            
            arrayPoint.removeLast()
            generate_map()
            create_map()
            moveAvatar()
            keysUpdateOnTimerTik()
            
            dx = 0
        }else {
            timer.invalidate()
        }
    }
    
    fileprivate func moveAvatar() {
//        car.position = Points[Points.count - x]
//
        let move = SKAction.move(to: Points[Points.count - x], duration: 0.5)
        car.run(move)
//        let moveBottomLeft = SKAction.move(to: Points[Points.count - x], duration:0.3)
//        car.run(moveBottomLeft)
    }
    
    func restart(){
        let transition = SKTransition.fade(with: .black, duration: 15)
        let restartScene = GameScene()
        restartScene.size = self.size
        restartScene.scaleMode = .fill
        self.view?.presentScene(restartScene, transition: transition)
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode{
        case 123:
            left.pressed()
        case 124:
            right.pressed()
        default:
            print(event.keyCode)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode{
        case 123:
            left.release()
        case 124:
            right.release()
        default:
            print(event.keyCode)
        }
    }
    
    class Key{
        var status = 0 // 0 - pusteny, 1 - stlaceny, 2 - impulz, 3 - drzany
        
        func tik(){
            if status == 1{
                status = 3
            } else if status == 2{
                status = 0
                // pohyb
            } else if status == 3{
                //pohyb
            }
        }
        
        func pressed(){
            if status == 0{
                status = 1
            } else if status == 2 {
                status = 1
            }
        }
        
        func release(){
            if status == 1{
                status = 2
            } else if status == 3 {
                status = 0
            }
        }
    }
}

