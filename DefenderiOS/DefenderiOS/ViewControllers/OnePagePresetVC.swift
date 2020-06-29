//
//  OnePagePresetVC.swift
//  DefenderiOS
//
//  Created by Derek Knight on 27/06/20.
//  Copyright © 2020 Derek Knight. All rights reserved.
//

import UIKit


protocol OnePagePresetVCDelegate {
    func settingsDidChangeForPreset(_ sender: OnePagePresetVC, preset: DXPreset?)
}

class OnePagePresetVC: UIViewController {
    
    var presetDelegate: OnePagePresetVCDelegate?
    
    var controlsVC: ControlsVC?
    var cabinetVC: CabinetVC?
    var pedal1VC: PedalVC?
    var pedal2VC: PedalVC?
    var pedal3VC: PedalVC?
    var pedal4VC: PedalVC?
    var effect1VC: EffectVC?
    var effect2VC: EffectVC?
    var effect3VC: EffectVC?
    var effect4VC: EffectVC?

    internal var powerState: PowerState = .off {
        didSet {
            controlsVC?.powerState = powerState
            cabinetVC?.powerState = powerState
            pedal1VC?.powerState = powerState
            pedal2VC?.powerState = powerState
            pedal3VC?.powerState = powerState
            pedal4VC?.powerState = powerState
            effect1VC?.powerState = powerState
            effect2VC?.powerState = powerState
            effect3VC?.powerState = powerState
            effect4VC?.powerState = powerState
        }
    }
    
    internal var preset: DXPreset? {
        didSet {
            controlsVC?.configureWith(preset: preset)
            cabinetVC?.configureWith(preset: preset)
            effects = preset?.effects
        }
    }
    
    fileprivate var effects: [DXEffect]? {
        didSet {
            pedal1VC?.configureWith(pedal: nil)
            pedal2VC?.configureWith(pedal: nil)
            pedal3VC?.configureWith(pedal: nil)
            pedal4VC?.configureWith(pedal: nil)
            effect1VC?.configureWith(effect: nil)
            effect2VC?.configureWith(effect: nil)
            effect3VC?.configureWith(effect: nil)
            effect4VC?.configureWith(effect: nil)

            for effect in effects ?? [] {
                if effect.slot == 0 { pedal1VC?.configureWith(pedal: effect) }
                if effect.slot == 1 { pedal2VC?.configureWith(pedal: effect) }
                if effect.slot == 2 { pedal3VC?.configureWith(pedal: effect) }
                if effect.slot == 3 { pedal4VC?.configureWith(pedal: effect) }
                if effect.slot == 4 { effect1VC?.configureWith(effect: effect) }
                if effect.slot == 5 { effect2VC?.configureWith(effect: effect) }
                if effect.slot == 6 { effect3VC?.configureWith(effect: effect) }
                if effect.slot == 7 { effect4VC?.configureWith(effect: effect) }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedControls":
                controlsVC = segue.destination as? ControlsVC
                controlsVC?.delegate = self
            case "embedPedal1":
                pedal1VC = segue.destination as? PedalVC
                pedal1VC?.slotNumber = 0
                pedal1VC?.delegate = self
            case "embedPedal2":
                pedal2VC = segue.destination as? PedalVC
                pedal2VC?.slotNumber = 1
                pedal2VC?.delegate = self
            case "embedPedal3":
                pedal3VC = segue.destination as? PedalVC
                pedal3VC?.slotNumber = 2
                pedal3VC?.delegate = self
            case "embedPedal4":
                pedal4VC = segue.destination as? PedalVC
                pedal4VC?.slotNumber = 3
                pedal4VC?.delegate = self
            case "embedEffect1":
                effect1VC = segue.destination as? EffectVC
                effect1VC?.slotNumber = 4
                effect1VC?.delegate = self
            case "embedEffect2":
                effect2VC = segue.destination as? EffectVC
                effect2VC?.slotNumber = 5
                effect2VC?.delegate = self
            case "embedEffect3":
                effect3VC = segue.destination as? EffectVC
                effect3VC?.slotNumber = 6
                effect3VC?.delegate = self
            case "embedEffect4":
                effect4VC = segue.destination as? EffectVC
                effect4VC?.slotNumber = 7
                effect4VC?.delegate = self
            case "embedCabinet":
                cabinetVC = segue.destination as? CabinetVC
                cabinetVC?.delegate = self
            default: break
            }
        }
    }
    
//    private func newControlsVC() -> BaseEffectVC {
//        guard let controlsVC = UIStoryboard(name: "Controls", bundle: nil).instantiateInitialViewController() as? ControlsVC else {
//            ULog.error("Unable to create controls view controller")
//            fatalError()
//        }
//        controlsVC.delegate = self
//        return controlsVC
//    }
//
//    private func newPedalVC(slotNumber: Int) -> BaseEffectVC {
//        guard let pedalVC = UIStoryboard(name: "Pedal", bundle: nil).instantiateInitialViewController() as? PedalVC else {
//            ULog.error("Unable to create a pedal view controller")
//            fatalError()
//        }
//        pedalVC.slotNumber = slotNumber
//        pedalVC.delegate = self
//        return pedalVC
//    }
//
//    private func newEffectVC(slotNumber: Int) -> BaseEffectVC {
//        guard let effectVC = UIStoryboard(name: "Effect", bundle: nil).instantiateInitialViewController() as? EffectVC else {
//                ULog.error("Unable to create a effect view controller")
//                fatalError()
//        }
//        effectVC.slotNumber = slotNumber
//        effectVC.delegate = self
//        return effectVC
//    }
//
//    fileprivate func replaceEffect(_ effect: DXEffect, inSlot: Int) {
//        if effects != nil {
//            for index in 0..<effects!.count {
//                if effects![index].slot == effect.slot {
//                    effects![index] = effect
//                }
//            }
//        }
//        preset?.effects = effects
//    }
}

// // MARK: UIPageViewControllerDataSource
//
//extension OnePagePresetVC: UIPageViewControllerDataSource {
//
//    func pageViewController(_ pageViewController: UIPageViewController,
//                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let effectVC: BaseEffectVC = viewController as? BaseEffectVC else { return nil }
//        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: effectVC) else { return nil }
//
//        let previousIndex = viewControllerIndex - 1
//
//        guard previousIndex >= 0 else { return nil }
//        guard orderedViewControllers.count > previousIndex else { return nil }
//
//        return orderedViewControllers[previousIndex]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController,
//                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let effectVC: BaseEffectVC = viewController as? BaseEffectVC else { return nil }
//        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: effectVC) else { return nil }
//
//        let nextIndex = viewControllerIndex + 1
//        let orderedViewControllersCount = orderedViewControllers.count
//
//        guard orderedViewControllersCount != nextIndex else { return nil }
//        guard orderedViewControllersCount > nextIndex else { return nil }
//
//        return orderedViewControllers[nextIndex]
//    }
//}
//
extension OnePagePresetVC: ControlsVCDelegate {
    
    func settingsDidChangeForControls(_ sender: ControlsVC, preset: DXPreset?) {
        ULog.verbose("Changed controls for preset")
        self.preset = preset
        presetDelegate?.settingsDidChangeForPreset(self, preset: preset)
    }
}

extension OnePagePresetVC: PedalVCDelegate {
    
    func settingsDidChangeForPedal(_ sender: PedalVC, slotNumber: Int, effect: DXEffect) {
        ULog.verbose("Changed Pedal in slot %d", slotNumber)
//        replaceEffect(effect, inSlot: slotNumber)
        presetDelegate?.settingsDidChangeForPreset(self, preset: preset)
    }
}

extension OnePagePresetVC: EffectVCDelegate {
    
    func settingsDidChangeForEffect(_ sender: EffectVC, slotNumber: Int, effect: DXEffect) {
        ULog.verbose("Changed Effect in slot %d", slotNumber)
//        replaceEffect(effect, inSlot: slotNumber)
        presetDelegate?.settingsDidChangeForPreset(self, preset: preset)
    }
}

extension OnePagePresetVC: CabinetVCDelegate {
    
    func settingsDidChangeForCabinet(_ sender: CabinetVC, slotNumber: Int, effect: DXEffect) {
        ULog.verbose("Changed Cabinet in slot %d", slotNumber)
//        replaceEffect(effect, inSlot: slotNumber)
        presetDelegate?.settingsDidChangeForPreset(self, preset: preset)
    }
}
