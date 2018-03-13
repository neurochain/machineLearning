# -*- coding: utf-8 -*-
"""
Created on Wed Aug 30 11:33:06 2017

@author: NeuroChain 
"""

from Signal import WaveSignal
import numpy as np
import os
import time
#from threading import thread

#print(os.getcwd())

#JohnLegend =  WaveSignal()
#JohnLegend.initialisation("./Musiques/Pop/LadyGaga-BadRomance.mp3")
#JohnLegend.printInfo()
##JohnLegend.plotSignal(envelop = True)
#print("rapport amplitude : ", JohnLegend.rapportAmp())
#JohnLegend.tableDonnees("Test.csv")

tt = time.time()

parole = WaveSignal()
parole.initialisation("./Test/Electronique/Ocean_Shiver_-_Night_Train.mp3")
parole.plotSignal()




#files = os.listdir("./Musiques")
#
#print(files)
#print("\n")
#
#fichier = open("TestSolo.csv", 'w')
#
##fichier.write("Title;" + "intro;" + "temporalCentroid;"  +  "pulsation (bpm);" +
##              "spectralCentroid;" + "spectralSpread;" + "spectralSkewness;" + "spectralKurtosis;" + 
##              "1st;" + "2nd;" + "3rd;" + "4th;" + "5th;" + "6th;" + "7th;" + "8th;" + "9th;" + "10th;" + 
##              "11th;" + "12th;" + "13th MFCC;" + "genre")
#
#fichier.write("Title;" + "intro;" + "temporalCentroid;"  +
#              "spectralCentroid;" + "spectralSpread;" + "spectralSkewness;" + "spectralKurtosis;" + 
#              "1st;" + "2nd;" + "3rd;" + "4th;" + "5th;" + "6th;" + "7th;" + "8th;" + "9th;" + "10th;" + 
#              "11th;" + "12th;" + "13th MFCC;" + "genre")
#
#fichier.close()
#
#
#for i in np.arange(len(files)):
#    
#    songs = os.listdir("./Musiques/" + files[i])
#    
#    for j in np.arange(len(songs)):
#        print("\n")
#        
#        if (songs[j][-3:] == "mp3" or songs[j][-3:] == "wav"):            
#            musique = WaveSignal()
#            musique.initialisation("./Musiques/" + files[i] + "/" + songs[j])
#            musique.printInfo()
#            musique.tableDonnees("TestSolo.csv")
#            
#            with open("TestSolo.csv", 'a') as file:
#                file.write(files[i])
#    
#print("temps d'execution : ", time.time() - tt)

#adele = WaveSignal()
#adele.initialisation("./Musiques/Adele-SomeoneLikeYou.wav")
#adele.printInfo()
##adele.plotSignal(envelop = True)
##adele.TFCTSignal()
##adele.Attaque()
#adele.tableDonnees("DonneesMusicales.csv")


#alicia = WaveSignal()
#alicia.initialisation("AliciaKeys-GirlOnFire.mp3")
#alicia.printInfo()
##alicia.plotSignal(envelop = True)
##alicia.TFCTSignal()
#alicia.Attaque()


#rihanna = WaveSignal()
#rihanna.initialisation("Rihanna-Diamonds.mp3")
#rihanna.printInfo()
##rihanna.plotSignal(envelop = True)
#rihanna.Attaque()
#rihanna.TFCTSignal()


#beyonce = WaveSignal()
#beyonce.initialisation("Beyonce-Halo.mp3")
#beyonce.printInfo()
##beyonce.plotSignal(envelop = True)
#beyonce.Attaque()
#beyonce.TFCTSignal()


#maahlox = WaveSignal()
#maahlox.initialisation("MAAHLOX-LesSorciers.mp3")
#maahlox.printInfo()
#maahlox.plotSignal(envelop = True)


#maahlox2 = WaveSignal()
#maahlox2.initialisation("MAAHLOX-VistaVie.mp3")
#maahlox2.printInfo()
#maahlox2.plotSignal(envelop = True)


#newlife = WaveSignal()
#newlife.initialisation("ExplosiveEarCandy-NewLife.mp3")
#newlife.printInfo()
#newlife.plotSignal(envelop = True)
#newlife.Attaque()


#sister = WaveSignal()
#sister.initialisation("SISTER-TheGlassChild.mp3")
#sister.printInfo()
##sister.Attaque()
##sister.plotSignal(envelop = True)
#sister.TFCTSignal()


#crown = WaveSignal()
#crown.initialisation("KelleeMaize-Crown.mp3")
#crown.printInfo()
#crown.envelope(plot = True)


#daphnee =  WaveSignal()
#daphnee.initialisation("Daphne-MotherLove.mp3")
#daphnee.printInfo()
#daphnee.envelope(plot = True)



#Leo =  WaveSignal()
#Leo.initialisation("MrLeo-Kemayo.mp3")
#Leo.printInfo()
#Leo.plotSignal()
#Leo.envelope(plot = True)



#Locko =  WaveSignal()
#Locko.initialisation("Locko-JeSeraiLa.mp3")
#Locko.printInfo()
#Locko.plotSignal()



#Charlotte =  WaveSignal()
#Charlotte.initialisation("CharlotteDipanda-NdoloBukate.mp3")
#Charlotte.printInfo()
#Charlotte.plotSignal()



#LadyPonce =  WaveSignal()
#LadyPonce.initialisation("LadyPonce-MeNdiguiYem.mp3")
#LadyPonce.printInfo()
#LadyPonce.plotSignal()



#Labl =  WaveSignal()
#Labl.initialisation("LABL-maVeWaNgan.mp3")
#Labl.printInfo()
#Labl.plotSignal()



#Locko2 =  WaveSignal()
#Locko2.initialisation("Locko-SawaRomance.mp3")
#Locko2.printInfo()
#Locko2.plotSignal()



#JohnLegend =  WaveSignal()
#JohnLegend.initialisation("JohnLegend-AllofMe.mp3")
#JohnLegend.printInfo()
#JohnLegend.plotSignal()




#Gims =  WaveSignal()
#Gims.initialisation("MaîtreGims-SapesCommeJamais.mp3")
#Gims.printInfo()
#Gims.plotSignal()
