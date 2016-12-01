//
//  EffectsVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
import Flogger

class EffectsVC: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    internal var powerState: PowerState = .off {
        didSet {
            for pageVC in orderedViewControllers {
                if let controlsVC = pageVC as? ControlsVC {
                    controlsVC.powerState = powerState
                } else if let pedalVC = pageVC as? PedalVC {
                    pedalVC.powerState = powerState
                } else if let effectVC = pageVC as? EffectVC {
                    effectVC.powerState = powerState
                }
            }
        }
    }
    
    internal var preset: DXPreset? {
        didSet {
            for pageVC in orderedViewControllers {
                if let controlsVC = pageVC as? ControlsVC {
                    controlsVC.configureWith(preset: preset)
                }
            }
            self.effects = preset?.effects
        }
    }
    
    private var effects: [DXEffect]? {
        didSet {
            for pageVC in orderedViewControllers {
                if let pedalVC = pageVC as? PedalVC {
                    pedalVC.configureWith(pedal: nil)
                } else if let effectVC = pageVC as? EffectVC {
                    effectVC.configureWith(effect: nil)
                }
            }
            for effect in effects ?? [] {
                for pageVC in orderedViewControllers {
                    if let pedalVC = pageVC as? PedalVC {
                        if pedalVC.slotNumber == effect.slot {
                            pedalVC.configureWith(pedal: effect)
                        }
                    } else if let effectVC = pageVC as? EffectVC {
                        if effectVC.slotNumber == effect.slot {
                            effectVC.configureWith(effect: effect)
                        }
                    }
                }
            }
        }
    }

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newControlsVC(),
                self.newPedalVC(slotNumber: 0),
                self.newPedalVC(slotNumber: 1),
                self.newPedalVC(slotNumber: 2),
                self.newPedalVC(slotNumber: 3),
                self.newEffectVC(slotNumber: 4),
                self.newEffectVC(slotNumber: 5),
                self.newEffectVC(slotNumber: 6),
                self.newEffectVC(slotNumber: 7)]
    }()
    
    private func newControlsVC() -> UIViewController {
        guard let controlsVC = UIStoryboard(name: "Controls", bundle: nil).instantiateInitialViewController() as? ControlsVC else {
            Flogger.log.error("Unable to create controls view controller")
            fatalError()
        }
        return controlsVC
    }
    
    private func newPedalVC(slotNumber: Int) -> UIViewController {
        guard let pedalVC = UIStoryboard(name: "Pedal", bundle: nil).instantiateInitialViewController() as? PedalVC else {
            Flogger.log.error("Unable to create a pedal view controller")
            fatalError()
        }
        pedalVC.slotNumber = slotNumber
        return pedalVC
    }
    
    private func newEffectVC(slotNumber: Int) -> UIViewController {
        guard let effectVC = UIStoryboard(name: "Effect", bundle: nil).instantiateInitialViewController() as? EffectVC else {
                Flogger.log.error("Unable to create a effect view controller")
                fatalError()
        }
        effectVC.slotNumber = slotNumber
        return effectVC
    }
    
}

// MARK: UIPageViewControllerDataSource

extension EffectsVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
