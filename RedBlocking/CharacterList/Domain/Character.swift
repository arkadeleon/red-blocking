//
//  Character.swift
//  RedBlocking
//
//  Created by Leon Li on 2018/6/19.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

enum Character: CaseIterable {
    case alex
    case chunLi
    case dudley
    case elena
    case gill
    case gouki
    case hugo
    case ibuki
    case ken
    case makoto
    case necro
    case oro
    case q
    case remy
    case ryu
    case sean
    case twelve
    case urien
    case yang
    case yun

    var isLocked: Bool {
        self == .gill
    }

    var name: String {
        switch self {
        case .alex:   return "Alex"
        case .chunLi: return "Chun-Li"
        case .dudley: return "Dudley"
        case .elena:  return "Elena"
        case .gill:   return "Gill"
        case .gouki:  return "Gouki"
        case .hugo:   return "Hugo"
        case .ibuki:  return "Ibuki"
        case .ken:    return "Ken"
        case .makoto: return "Makoto"
        case .necro:  return "Necro"
        case .oro:    return "Oro"
        case .q:      return "Q"
        case .remy:   return "Remy"
        case .ryu:    return "Ryu"
        case .sean:   return "Sean"
        case .twelve: return "Twelve"
        case .urien:  return "Urien"
        case .yang:   return "Yang"
        case .yun:    return "Yun"
        }
    }

    var rowImageName: String {
        switch self {
        case .alex:   return "AlexHead"
        case .chunLi: return "Chun-LiHead"
        case .dudley: return "DudleyHead"
        case .elena:  return "ElenaHead"
        case .gill:   return "GillHead"
        case .gouki:  return "GoukiHead"
        case .hugo:   return "HugoHead"
        case .ibuki:  return "IbukiHead"
        case .ken:    return "KenHead"
        case .makoto: return "MakotoHead"
        case .necro:  return "NecroHead"
        case .oro:    return "OroHead"
        case .q:      return "QHead"
        case .remy:   return "RemyHead"
        case .ryu:    return "RyuHead"
        case .sean:   return "SeanHead"
        case .twelve: return "TwelveHead"
        case .urien:  return "UrienHead"
        case .yang:   return "YangHead"
        case .yun:    return "YunHead"
        }
    }

    var backgroundImageName: String {
        switch self {
        case .alex:   return "AlexBody"
        case .chunLi: return "Chun-LiBody"
        case .dudley: return "DudleyBody"
        case .elena:  return "ElenaBody"
        case .gill:   return "GillBody"
        case .gouki:  return "GoukiBody"
        case .hugo:   return "HugoBody"
        case .ibuki:  return "IbukiBody"
        case .ken:    return "KenBody"
        case .makoto: return "MakotoBody"
        case .necro:  return "NecroBody"
        case .oro:    return "OroBody"
        case .q:      return "QBody"
        case .remy:   return "RemyBody"
        case .ryu:    return "RyuBody"
        case .sean:   return "SeanBody"
        case .twelve: return "TwelveBody"
        case .urien:  return "UrienBody"
        case .yang:   return "YangBody"
        case .yun:    return "YunBody"
        }
    }

    var moveResourceName: String {
        switch self {
        case .alex:   return "Alex.yml"
        case .chunLi: return "Chun-Li.yml"
        case .dudley: return "Dudley.yml"
        case .elena:  return "Elena.yml"
        case .gill:   return "Gill.yml"
        case .gouki:  return "Gouki.yml"
        case .hugo:   return "Hugo.yml"
        case .ibuki:  return "Ibuki.yml"
        case .ken:    return "Ken.yml"
        case .makoto: return "Makoto.yml"
        case .necro:  return "Necro.yml"
        case .oro:    return "Oro.yml"
        case .q:      return "Q.yml"
        case .remy:   return "Remy.yml"
        case .ryu:    return "Ryu.yml"
        case .sean:   return "Sean.yml"
        case .twelve: return "Twelve.yml"
        case .urien:  return "Urien.yml"
        case .yang:   return "Yang.yml"
        case .yun:    return "Yun.yml"
        }
    }
}
