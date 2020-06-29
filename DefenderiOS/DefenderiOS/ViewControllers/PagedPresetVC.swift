//
//  PresetVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

protocol PagedPresetVCDelegate {
    func settingsDidChangeForPreset(_ sender: PagedPresetVC, preset: DXPreset?)
}

class PagedPresetVC: UIPageViewController {
    
    var presetDelegate: PagedPresetVCDelegate?
    
    internal var powerState: PowerState = .off {
        didSet {
            for pageVC in orderedViewControllers {
                pageVC.powerState = powerState
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
            effects = preset?.effects
        }
    }
    
    fileprivate var effects: [DXEffect]? {
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

    private(set) lazy var orderedViewControllers: [BaseEffectVC] = {
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
    
    private func newControlsVC() -> BaseEffectVC {
        guard let controlsVC = UIStoryboard(name: "Controls", bundle: nil).instantiateInitialViewController() as? ControlsVC else {
            ULog.error("Unable to create controls view controller")
            fatalError()
        }
        controlsVC.delegate = self
        return controlsVC
    }
    
    private func newPedalVC(slotNumber: Int) -> BaseEffectVC {
        guard let pedalVC = UIStoryboard(name: "Pedal", bundle: nil).instantiateInitialViewController() as? PedalVC else {
            ULog.error("Unable to create a pedal view controller")
            fatalError()
        }
        pedalVC.slotNumber = slotNumber
        pedalVC.delegate = self
        return pedalVC
    }
    
    private func newEffectVC(slotNumber: Int) -> BaseEffectVC {
        guard let effectVC = UIStoryboard(name: "Effect", bundle: nil).instantiateInitialViewController() as? EffectVC else {
                ULog.error("Unable to create a effect view controller")
                fatalError()
        }
        effectVC.slotNumber = slotNumber
        effectVC.delegate = self
        return effectVC
    }
    
    fileprivate func replaceEffect(_ effect: DXEffect, inSlot: Int) {
        if effects != nil {
            for index in 0..<effects!.count {
                if effects![index].slot == effect.slot {
                    effects![index] = effect
                }
            }
        }
        preset?.effects = effects
    }
}

// MARK: UIPageViewControllerDataSource

extension PagedPresetVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let effectVC: BaseEffectVC = viewController as? BaseEffectVC else { return nil }
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: effectVC) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let effectVC: BaseEffectVC = viewController as? BaseEffectVC else { return nil }
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: effectVC) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
}

extension PagedPresetVC: ControlsVCDelegate {
    
    func settingsDidChangeForControls(_ sender: ControlsVC, preset: DXPreset?) {
        ULog.verbose("Changed controls for preset")
        self.preset = preset
        presetDelegate?.settingsDidChangeForPreset(self, preset: preset)
    }
}

extension PagedPresetVC: PedalVCDelegate {
    
    func settingsDidChangeForPedal(_ sender: PedalVC, slotNumber: Int, effect: DXEffect) {
        ULog.verbose("Changed Pedal in slot %d", slotNumber)
        replaceEffect(effect, inSlot: slotNumber)
        presetDelegate?.settingsDidChangeForPreset(self, preset: preset)
    }
}

extension PagedPresetVC: EffectVCDelegate {
    
    func settingsDidChangeForEffect(_ sender: EffectVC, slotNumber: Int, effect: DXEffect) {
        ULog.verbose("Changed Effect in slot %d", slotNumber)
        replaceEffect(effect, inSlot: slotNumber)
        presetDelegate?.settingsDidChangeForPreset(self, preset: preset)
    }
}
