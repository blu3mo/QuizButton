//
//  HomeModel.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2020/06/28.
//  Copyright © 2020 Shutaro Aoyama. All rights reserved.
//

import Foundation
import MultipeerConnectivity

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
    func changeScreenByResult(result: GameResult)
}

protocol JudgeModelConnectionOutput: class{
    var isConnected: Bool { get }
    
    func sendMessage(message: Message)
    func advertise()
    func getBrowser() -> MCBrowserViewController
}

protocol JudgeModelProtocol {
    
    var presenter: JudgeModelPresenterOutput! { get set }
    var connectionService: JudgeModelConnectionOutput! { get set }
    
    var gameState: GameState { get set }
    
    var lastTriedDate: Date { get set }
    
    func reactMessage(message: Message)
    func tryAnswering()
}


final class JudgeModel: JudgeModelProtocol {
    
    weak var presenter: JudgeModelPresenterOutput!
    weak var connectionService: JudgeModelConnectionOutput!
    
    var gameState: GameState
    
    var lastTriedDate: Date

    init(presenter: JudgeModelPresenterOutput, connectionService: JudgeModelConnectionOutput) {
        self.presenter = presenter
        self.connectionService = connectionService
        
        gameState = .open
        
        lastTriedDate = Date(timeIntervalSince1970: 0)
    }

    func reactMessage(message: Message) {
        switch message {
        case .youWin:
            if gameState != .done {
                gameState = .done
                presenter.changeScreenByResult(result: .won)
            }
        case .triedDate(let opponentDate):
            
            switch gameState {
            case .open: //clearly lost the game
                presenter.changeScreenByResult(result: .lost)
                gameState = .done
                connectionService.sendMessage(message: .youWin)
            case .waiting: //comparing date
                if opponentDate < lastTriedDate {
                    presenter.changeScreenByResult(result: .lost)
                } else {
                    presenter.changeScreenByResult(result: .won)
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
    
}
