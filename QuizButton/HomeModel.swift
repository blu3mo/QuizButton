//
//  HomeModel.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2020/06/28.
//  Copyright © 2020 Shutaro Aoyama. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol HomeModelProtocol {
    var presenter: HomeModelPresenterOutput! { get set }
    var connectionService: HomeModelConnectionOutput! { get set }
    
    func recievedMessage(message: Message)
    func pushedButton()
}

protocol HomeModelPresenterOutput: class{
    //UIにつながる処理
}

protocol HomeModelConnectionOutput: class{
    func sendMessage(message: Message)
    func advertise()
    func getBrowser() -> MCBrowserViewController
}

enum Message {
    case youWin
    case pushedDate(Date)
}

final class HomeModel: HomeModelProtocol {
    
    weak var presenter: HomeModelPresenterOutput!
    weak var connectionService: HomeModelConnectionOutput!

    init(presenter: HomeModelPresenterOutput, connectionService: HomeModelConnectionOutput) {
        self.presenter = presenter
        self.connectionService = connectionService
    }

    func recievedMessage(message: Message) {
        
    }
    
    func pushedButton() {
        connectionService.sendMessage(message: Message.pushedDate(<#T##Date#>))
    }
    
}
