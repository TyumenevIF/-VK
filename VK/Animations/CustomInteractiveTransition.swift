//
//  CustomInteractiveTransition.swift
//  HomeWork4
//
//  Created by Ilyas Tyumenev on 23/07/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

class CustomInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // Добавим свойство, которое будет хранить UIViewController - экран, для которого будет выполняться интерактивный переход
    var viewController: UIViewController? {
        didSet {
            let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgeGesture(_:)))
            recognizer.edges = [.left]
            viewController?.view.addGestureRecognizer(recognizer)
        }
    }    
    
    var hasStarted: Bool = false
    var shouldFinish: Bool = false
    
    @objc func handleScreenEdgeGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        
        // Обработка состояний распознователя
        switch recognizer.state {
        
        // Когда распознавание началось, меняем свойство hasStarted на true, обозначая, что интерактивный переход начался.
        // Также в этот момент вызываем метод popViewController у navigationController экрана, чтобы начать переход.
        case .began:
            self.hasStarted = true
            self.viewController?.navigationController?.popViewController(animated: true)
            
        // Когда распознаватель перешел в состояние changed, рассчитываем процент, на который изменился переход.
        // Для этого делим координаты текущего положения пальца на ширину view, на котором происходит жест.
        // Добавляем ограничения, чтобы это число было не больше 1 и не меньше 0. После этого присваиваем свойству shouldFinish значение,
        // которое зависит от прогресса. Если он больше 0,33 — true. В завершение вызываем метод update с текущим прогрессом.
        
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            let relativeTranslation = translation.x / (recognizer.view?.bounds.width ?? 1)
            let progress = max(0, min(1, relativeTranslation))
            
            self.shouldFinish = progress > 0.33
            
            self.update(progress)
            
        // Когда жест закончился, меняем значение свойства hasStarted на false. Затем вызываем метод finish, если свойство shouldFinish
        // равно true, или cancel, если false.
        case .ended:
            self.hasStarted = false
            self.shouldFinish ? self.finish() : self.cancel()
            
        // Если переход был отменен, меняем значение свойства hasStarted на false и вызываем метод cancel.
        case .cancelled:
            self.hasStarted = false
            self.cancel()
            
        default:
            return
        }
    }
}
