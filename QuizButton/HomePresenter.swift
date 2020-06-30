//
//  HomePresenter.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2020/06/28.
//  Copyright © 2020 Shutaro Aoyama. All rights reserved.
//

import Foundation
import UIKit //本当はしたくない

enum BackgroundColor {
    case red
    case blue
    case black
}

protocol HomePresenterOutput: class {
    func showConnectionAlert()
    func showConnectionBrowser(view: UIViewController)
    
    func changeBackgroundColor(to color: BackgroundColor)
    func playBeepSound()
    
}

protocol HomePresenterProtocol {
    var view: HomePresenterOutput! { get set }
    var model: JudgeModelProtocol! { get set }
    func inject(model: JudgeModelProtocol)
    
    func connectButtonPressed()
    func hostSessionSelected()
    func joinSessionSelected()
    
    func answerButtonPressed()
    
    func resetButtonPressed()
    
}

final class HomePresenter: HomePresenterProtocol {
    
    internal weak var view: HomePresenterOutput!
    internal var model: JudgeModelProtocol!
    
    init(view: HomePresenterOutput) {
        self.view = view
    }
    
    func inject(model: JudgeModelProtocol) {
        self.model = model
    }
    
    func connectButtonPressed() {
        view.showConnectionAlert()
    }
    
    func hostSessionSelected() {
        model.advertise()
    }
    
    func joinSessionSelected() {
        let connectionBrowser = model.getConnectionBrowser()
        view.showConnectionBrowser(view: connectionBrowser)
    }
    
    func answerButtonPressed() {
        model.tryAnswering()
    }
    
    func resetButtonPressed() {
        model.resetGame()
        view.changeBackgroundColor(to: .black)
    }
    
}

extension HomePresenter: JudgeModelPresenterOutput {
    func changeViewByResult(result: GameResult) {
        switch result {
        case .won:
            view.changeBackgroundColor(to: .red)
            view.playBeepSound()
        case .lost:
            view.changeBackgroundColor(to: .blue)
        }
    }
}
