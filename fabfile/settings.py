# -*- coding: utf-8 -*-
import os

from unipath import Path
from fabric.api import *


env.kits = {
    'swat4': {
        'mod': 'Mod',
        'content': 'Content',
        'server': 'Swat4DedicatedServer.exe',
        'ini': 'Swat4DedicatedServer.ini',
    },
    'swat4exp': {
        'mod': 'ModX',
        'content': 'ContentExpansion',
        'server': 'Swat4XDedicatedServer.exe',
        'ini': 'Swat4XDedicatedServer.ini',
    },
}

env.roledefs = {
    'ucc': ['vm-ubuntu-swat'],
    'server': ['vm-ubuntu-swat'],
}

env.paths = {
    'here': Path(os.path.dirname(__file__)).parent,
}

env.paths.update({
    'dist': env.paths['here'].child('dist'),
    'compiled': env.paths['here'].child('compiled'),
})

env.ucc = {
    'path': Path('/home/sergei/swat4ucc/'),
    'git': 'git@home:public/swat4#origin/ucc-fake-am',
    'packages': (
        ('Utils', 'git@home:swat/swat-utils'),
        ('Julia', 'git@home:swat/swat-julia'),
        ('JuliaAdmin', 'git@home:swat/swat-julia-admin'),
    ),
}

env.server = {
    'path': Path('/home/sergei/swat4server/'),
    'git': 'git@home:public/swat4#origin/server-bs',
    'settings': {
        '+[Engine.GameEngine]': (
            'ServerActors=Utils.Package',
            'ServerActors=Julia.Core',
            'ServerActors=JuliaAdmin.Extension',
        ),
        # '[AMMod.AMGameMod]': (
        #     'DisableMod=True',
        # ),
        '[Julia.Core]': (
            'Enabled=True',
        ),
        # '[Julia.Cache]': (
        #     'CacheTime=10',
        # ),
        '[JuliaAdmin.Extension]': (
            'Enabled=True',
            'DisallowVIPVoice=True',
            'AutoBalance=True',
            'AutoBalanceTime=10',
            'AutoBalanceAction=',
            'AutoBalanceActionLimit=2',
            'DisallowWords=f*ck',
            'DisallowWordsAction=kick',
            'DisallowWordsActionLimit=2',
            'DisallowWordsIgnoreAdmins=False',
            'DisallowWordsAlertAdmins=True',
            'DisallowNames=*fu*ck*',
            'DisallowNames=cun*t',
            'DisallowNamesAction=forcemute',
            'DisallowNamesActionTime=10',
            'DisallowNamesActionWarnings=50',
            'ProtectNames=|MYT|* pass',
            'ProtectNames=serge    lol   ',
            'ProtectNames=foo   bar   ham ',
            'ProtectNamesAction=kickban',
            'ProtectNamesActionTime=300',
            'ProtectNamesActionWarnings=100',
            'ProtectNamesIgnoreAdmins=True',
            'FilterText=False',
            'FilterTextIgnoreAdmins=True',
            'FriendlyFire=(Weapons="TaSEr stun Gun",IgnoreAdmins=True,Alert=True,Action="kick",ActionLimit=2)',
            'FriendlyFire=(Weapons="Pepper Spray",Alert=True,ActionLimit=5,Action="forcelesslethal")',
            'FriendlyFire=(Weapons="Pepper-ball",Alert=True,ActionLimit=10,Action="forcelesslethal")',
            'FriendlyFire=(Weapons="Flashbang,Stinger",Alert=True,ActionLimit=5,Action="forcelesslethal")',
            'FriendlyFire=(Weapons="Less Lethal Shotgun",Alert=True,ActionLimit=5,Action="forcenoweapons")',
        ),
    }
}

env.dist = {
    'version': '1.1.1',
    'extra': (
        env.paths['here'].child('LICENSE'),
        env.paths['here'].child('README.html'),
        env.paths['here'].child('CHANGES.html'),
    )
}
