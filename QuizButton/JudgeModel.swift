//
//  HomeModel.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2020/06/28.
//  Copyright © 2020 Shutaro Aoyama. All rights reserved.
//

import Foundation
import UIKit //本当はしたくない

enum GameResult {
    case won
    case lost
}

enum Message {
    case youWin
    case triedDate(Date)
}

enum GameState {
    case open
    case waiting
    case done
}

protocol JudgeModelPresenterOutput: class{
    func changeViewByResult(result: GameResult)
}

protocol JudgeModelConnectionOutput: class{
    var isConnected: Bool { get }
    
    func sendMessage(message: Message)
    func advertise()
    func getBrowser() -> UIViewController
}

protocol JudgeModelProtocol {
    
    var presenter: JudgeModelPresenterOutput! { get set }
    var connectionService: JudgeModelConnectionOutput! { get set }
    
    var gameState: GameState { get set }
    
    var lastTriedDate: Date { get set }
    
    func getConnectionBrowser() -> UIViewController
    func advertise()
    
    func reactMessage(message: Message)
    func tryAnswering()
    
    func resetGame()
}


final class JudgeModel: JudgeModelProtocol {
    
    internal weak var presenter: JudgeModelPresenterOutput!
    internal weak var connectionService: JudgeModelConnectionOutput!
    
    var gameState: GameState
    
    var lastTriedDate: Date

    init(presenter: JudgeModelPresenterOutput, connectionService: JudgeModelConnectionOutput) {
        self.presenter = presenter
        self.connectionService = connectionService
        
        gameState = .open
        
        lastTriedDate = Date(timeIntervalSince1970: 0)
    }

    func getConnectionBrowser() -> UIViewController{
        return connectionService.getBrowser()
    }
    
    func advertise() {
        connectionService.advertise()
    }
    
    func reactMessage(message: Message) {
        switch message {
        case .youWin:
            if gameState != .done {
                gameState = .done
                presenter.changeViewByResult(result: .won)
            }
        case .triedDate(let opponentDate):
            
            switch gameState {
            case .open: //clearly lost the game
                presenter.changeViewByResult(result: .lost)
                gameState = .done
                connectionService.sendMessage(message: .youWin)
            case .waiting: //comparing date
                if opponentDate < lastTriedDate {
                    presenter.changeViewByResult(result: .lost)
                } else {
                    presenter.changeViewByResult(result: .won)
                }
                gameState = .done
            case .done:
                break
            }
            
        }
    }
    
    func tryAnswering() {
        lastTriedDate = Date()
        
        guard connectionService.isConnected else { return }
        
        switch gameState {
        case .open:
            gameState = .waiting
        
            let message = Message.triedDate(Date())
            connectionService.sendMessage(message: message)
        default:
            break
        }
    }
    
    func resetGame() {
        gameState = .open
    }
    
}
