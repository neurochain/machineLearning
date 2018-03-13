# -*- coding: utf-8 -*-
"""
Created on Wed Sep 13 18:28:52 2017

@author: NeuroChain 
"""

import numpy as np

def mel2freq(mel):
    freq = 700 * (np.exp(mel/1125) - 1)
        
    return freq
    
    
def freq2mel(freq):
    mel = 1125 * np.log(1 + freq/700)
        
    return mel