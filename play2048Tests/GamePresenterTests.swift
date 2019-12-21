//
//  GamePresenterTests.swift
//  play2048Tests
//
//  Created by Andrew Tokeley on 21/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import XCTest
@testable import play2048
class InteractorViewMock: Interactor, GameInteractorApi {
    
    func newGame() {
        <#code#>
    }
    
    func moveTiles(direction: Direction, completion: ((Bool, Int, Int) -> Void)?) {
        <#code#>
    }
    
    func getHighScores(completion: (([Score], Error?) -> Void)?) {
        <#code#>
    }
    
    func checkScore(scoreValue: Int, completion: ((Bool, Bool) -> Void)?) {
        <#code#>
    }
    
    func saveScore(score: Score, completion: (() -> Void)?) {
        <#code#>
    }
    
}

class GameViewMock: UserInterface, GameViewApi {
    func showNewGameOverlay(show: Bool) {
        //
    }
    
    func displayTileSet(tileSet: TileSet) {
        //
    }
    
    func displayScore(scoreValue: Int) {
        //
    }
    
    func displayHighScore(scoreValue: Int) {
        //
    }
    
    func displayGameOverMessage(message: String) {
        //
    }
    
    func displayMessage(title: String, message: String, completion: (() -> Void)?) {
        //
    }
    
    func displayMessageAndGetString(title: String, message: String, completion: ((String) -> Void)?) {
        //
    }
    
    
}

class GamePresenterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSwippingChangesScoreDisplay() {
        let module = AppModules.game.build()
        if let presenter = module.presenter as? GamePresenter {
            presenter.didSwipe(direction: .left)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
