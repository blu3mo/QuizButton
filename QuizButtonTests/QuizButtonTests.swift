//
//  QuizButtonTests.swift
//  QuizButtonTests
//
//  Created by Shutaro Aoyama on 2019/04/16.
//  Copyright © 2019 Shutaro Aoyama. All rights reserved.
//

import XCTest
import MultipeerConnectivity
@testable import QuizButton

class MCServiceStub: ConnectionServiceProtocol{
    var model: JudgeModelProtocol!
    
    var returningMessage: Message!
    
    init(returningMessage: Message) {
        self.returningMessage = returningMessage
    }
    
    func inject(model: JudgeModelProtocol) {
        self.model = model
    }
    
    var peerId: MCPeerID!
    var mcSession: MCSession!
}

extension MCServiceStub: JudgeModelConnectionOutput {
    
    var isConnected: Bool {
        return true
    }
    
    func sendMessage(message: Message) {
        model.reactMessage(message: Message.triedDate(Date() + 10000))
        return
    }
    
    func advertise() {
        return
    }
    
    func getBrowser() -> UIViewController {
        return UIViewController()
    }
    
}

class QuizButtonTests: XCTestCase {
    
    var homeViewController: HomeViewController!
    var presenter: HomePresenter!
    var model: JudgeModel!
    var connectionService: MCServiceStub!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        homeViewController = (UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as! HomeViewController)
        
        presenter = HomePresenter(view: homeViewController)
        connectionService = MCServiceStub(returningMessage: .youWin)

        model = JudgeModel(presenter: presenter, connectionService: connectionService)
        
        presenter.inject(model: model)
        connectionService.inject(model: model)
        
        homeViewController.inject(presenter: presenter)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func reactionToAnswerButton_WhenWinningAlways() {
        connectionService.returningMessage = Message.youWin
        homeViewController.answerButtonTapped(UIButton())
        XCTAssertEqual(homeViewController.view.backgroundColor, UIColor.red)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func reactionToAnswerButton_WhenWinningByDate() {
        connectionService.returningMessage = Message.triedDate(Date() + 100)
        homeViewController.answerButtonTapped(UIButton())
        XCTAssertEqual(homeViewController.view.backgroundColor, UIColor.red)
    }
    
    func reactionToAnswerButton_WhenLosingByDate() {
        connectionService.returningMessage = Message.triedDate(Date() - 100)
        homeViewController.answerButtonTapped(UIButton())
        XCTAssertEqual(homeViewController.view.backgroundColor, UIColor.blue)
    }
}
