//
//  HomePresenter.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2020/06/28.
//  Copyright © 2020 Shutaro Aoyama. All rights reserved.
//

import Foundation

protocol HomePresenterProtocol {
    
}

protocol HomePresenterOutput: class {
    
}

final class HomePresenter: HomePresenterProtocol {
    private weak var view: HomePresenterOutput!
    private var model: JudgeModelProtocol
    
    init(view: HomePresenterOutput) {
        self.view = view
    }
    
    func inject(model: JudgeModelProtocol) {
        self.model = model
    }
}

extension HomePresenter: JudgeModelPresenterOutput {
    
}
