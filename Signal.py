# -*- coding: utf-8 -*-
"""
Created on Tue Aug 29 17:04:56 2017

@author: NeuroChain 
"""

from pydub import AudioSegment
import numpy as np
import matplotlib.pyplot as plt
from detect_peaks import detect_peaks
from scipy.interpolate import interp1d
from scipy import signal
from scipy import fftpack
from functions import mel2freq, freq2mel
import time as t
#from diffrect import diffrect
#from filterbank import filterbank
#from hwindow import hwindow
#from timecomb import timecomb

class WaveSignal:

    

    def _init_(self):
        
        self.frequency = 0       # frequence echantillonnage
        self.duration = 0        # durée totale du signal 
        self.nom = ""    
        self.channel = 0         # nbre de chaines
        
    
    def initialisation(self, nomSong):
        
        """   constructeur de la classe   """
        
        if (nomSong[-3:] == "wav"):
            song = AudioSegment.from_wav(nomSong)   # lecture du signal
        elif (nomSong[-3:] == "mp3"):
            song = AudioSegment.from_mp3(nomSong)   # lecture du signal
                   
        sample = song.get_array_of_samples()    # récupération du signal encodé
        self.frequency = song.frame_rate        # frequence echantillonnage
        self.duration = song.duration_seconds   # durée totale du signal 
        self.nom = nomSong.split("/")[3][:len(nomSong.split("/")[3])-4]     # nom du song auquel on retire l'extension ".mp3" ou ".wav"
        self.channel = song.channels            # nbre de chaines
        
    
        if (self.channel == 2):

            # signal du côté gauche (channel 1)
            self.audioData = sample[::2]
            
            # signal du côté droit (channel 2)
#                self.audioData = sample[1::2]

        elif (self.channel == 1):
            self.audioData = sample
                
        self.normSignal()
        
        self.ampliEnveloppe = self.envelope()
        
    
            
    def printInfo(self):
        # informations sur le signal
        print("*************  info sur le signal *************")
        print("nom du signal : ", self.nom)
        print("nbre de voies du signal : ", self.channel)
        print("fréquence échantillonnage du signal (Hz) : ", self.frequency)
        print("durée totale du signal (s) : ", self.duration)
        print("nbre total d'échantillons du signal par voie : ", len(self.audioData))
        print("***********************************************")
        
    
    def plotSignal(self, envelop = False):
        """ traçage de courbes (signal et son enveloppe) """
    
        abscisse = np.arange(len(self.audioData))/self.frequency
        
        plt.rcParams['agg.path.chunksize'] = 10000   # permet d'avoir une fenetre plus grande
        plt.figure(num = 1, figsize = (16,3.5), dpi = 400)
        
        # representation graphique du signal
        # axe abscisse en minutes
        plt.plot(abscisse, self.audioData, color = 'b', label = 'signal')
        
        if (envelop == True):
            plt.plot(abscisse, self.ampliEnveloppe, color = 'r', label = 'enveloppe')
            plt.legend()
        
        plt.axis([0, self.duration, np.amin(self.audioData), np.amax(self.audioData)])
        plt.xlabel("time [sec]", fontsize = 14)
        plt.ylabel("amplitude", fontsize = 14)
        
        plt.savefig(self.nom +".png")
        
        
        
    def normSignal(self):
        """ normalisation du signal """
        
        maxi = np.amax(self.audioData)
        self.audioData = self.audioData/maxi
        
        
        
    def envelope(self):
        """ calcul enveloppe du signal 
            **************************
            biblio : 
            http://nbviewer.jupyter.org/github/demotu/BMC/blob/master/notebooks/DetectPeaks.ipynb """
         
        j = 0
        k = 0
        
        while (j == 0):
            #  mpd = minimum peak distance. On se fixe un minimum de 60 peaks. 
            # On évite aussi de détecter trop de pics sinon on prendra en compte toutes les oscillations
            # du signal
            mpd = len(self.audioData)/(60+5*k)
        
            # mph = minimum peak high
            indexes = detect_peaks(self.audioData, mph=0, mpd=mpd, threshold = 0, kpsh = False, show = False)
            ind = [] 
        
            if (indexes[0] > 0):
                ind.append(0)
        
            ind.extend(indexes)
        
            if (indexes[-1] < len(self.audioData) - 1):
                ind.append(len(self.audioData) - 1)

            indArray = np.array(ind)
            
            y_ind = [self.audioData[indexes[0]]]
            y_ind.extend(self.audioData[indexes])
            y_ind.append(self.audioData[indexes[-1]])
            y_indArray = np.array(y_ind)
        
            f = interp1d(indArray, y_indArray , kind = 'cubic')
            new_x = np.arange(indArray[0], indArray[-1] + 1)
            new_y = f(new_x)   # use interpolation function returned by `interp1d`
            
#            print ("nbre de peaks : ", len(indexes))
        
            delta = np.abs(new_y - self.audioData)
            
            if (np.amax(delta) > 2):
                k = k+1
            else:
                j = 1
                
            
            if (k == 15):
                j = 1

        return new_y
    
    
    
    def temporalCentroid(self):
        """ calcul du centre de gravité temporel [descripteur temporel] """
        
        time = np.arange(len(self.audioData))/self.frequency
        gravity = np.sum(time*self.ampliEnveloppe) / np.sum(self.ampliEnveloppe)
        
        return gravity
    
     # experimentations pour la detection de la freq fondamentale dans la voix parlee   
    def FreqFond(self):
        
        plt.figure()
#        plt.plot(abscisse, self.audioData, color = 'b', label = 'signal')
        plt.plot(self.audioData, color = 'b', label = 'signal')
        
        cepstrum = np.fft.fft(self.audioData[75000:76000])
        freq = np.fft.fftfreq(len(cepstrum), d = 1/self.frequency)
        
        plt.figure()
        plt.plot(freq, cepstrum, color = 'b', label = 'signal')
        plt.axis([0, 1500, np.amin(cepstrum), np.amax(cepstrum)])
        
        cepstrum = np.log(np.abs(cepstrum))
        
        plt.figure()
        plt.plot(freq, cepstrum, color = 'b', label = 'signal')
        plt.axis([0, 4000, np.amin(cepstrum), np.amax(cepstrum)])
        
#        fftpack.dct(cepstrum, norm = 'ortho', overwrite_x = True)
        cepstrum = np.fft.ifft(cepstrum)
        
        abscisse = np.arange(len(cepstrum))/self.frequency
        
        plt.figure()
        plt.plot(abscisse, cepstrum, color = 'b', label = 'signal')
        plt.axis([0, np.amax(abscisse), -0.08, 0.15])
#        return(cepstrum)

    
    
    def TFCTSignal(self, taille = 1024):
        """ calcul des descripteurs spectraux du signal 
                - Transformée de Fourier à Court terme
                    + Spectral centroid
                    + Spectral Skweness
                    + Spectral Kurtosis
                    + Spectral Spread
                - MFCC : Mel Frequency Cepstrum Coefficients (perception humaine des sons graves et aigus)       
        """
        
        
        """ retrait de ce descripteur car trop couteux en tps de calcul et n'ameliorait pas la performance
            des modeles de classification """
        ############################# pulsation musique (bpm) #############################
        
##        tt = t.time()
#        
#        print("3.1) pulsation par minute")
#        
#        maxfreq = self.frequency
#        sample_size = 5*maxfreq
#        
#        debut = int(0.5*len(self.audioData) - sample_size/2) 
#        fin = len(self.audioData) - debut
#        
#        short_sample = self.audioData[debut:fin]
#        
#        bandlimits = [0, 200, 400, 800, 1600, 3200]
#
#        # Implements beat detection algorithm for each song
#  
##        status = 'filtering song...'
##        print(status)
#        a = filterbank(short_sample, maxfreq = maxfreq)
##        status = 'windowing song...'
##        print(status)
#        b = hwindow(a, 0.2, maxfreq = maxfreq)
##        status = 'differentiating song...'
##        print(status)
#        c = diffrect(b)
##        status = 'comb filtering song...'
##        print(status)
#  
#        # Recursively calls timecomb to decrease computational time
#  
#        d = timecomb(c, acc = 2, minbpm = 60, maxbpm = 240, maxfreq = maxfreq)
#        e = timecomb(c, .5, d-2, d+2, bandlimits, maxfreq)
#        f = timecomb(c, .1, e-.5, e+.5, bandlimits, maxfreq)
#        g = timecomb(c, .01, f-.1, f+.1, bandlimits, maxfreq)
#        
#        bpm = g
#        
##        print("la pulsation de la musique est ", g, "bpm")
#  
##        print("temps d'execution FFT signal entier: ", int(t.time() - tt), "s")
        
        
        
        ############################# signal's spectrogramm #############################
        
        hopSize = 128     # pas "dt" de translation de la fenetre de Haming
        
        freq, time, fourierVect = signal.stft(self.audioData, self.frequency, window = 'hamming', 
                                              nperseg = taille, noverlap = hopSize)
        
        
        
        ############################# loudness #############################
        
#        loudness = np.zeros(len(time))
#        # spectralCentroid : moyenne de la distribution spectrale pour chaque unité temporelle
#        
#        for i in np.arange(len(time)):
#            for j in np.arange(len(freq)):
#                loudness[i] = loudness[i] + np.abs(fourierVect[j,i])**2
        
        
        
        ############################# spectral centroid #############################
        
        print("3.2) Spectral centroid")
        
        spectralCentroid = np.zeros(len(time))
        # spectralCentroid : moyenne de la distribution spectrale pour chaque unité temporelle
        
        for i in np.arange(len(time)):
            
            spectralCentroid[i] = np.sum(freq*np.abs(fourierVect[:,i]))
            somme = np.sum(np.abs(fourierVect[:,i]))
            
            if (somme < 1e-4):
                # detection des silences
                spectralCentroid[i] = 0
            else:
                spectralCentroid[i] = spectralCentroid[i] / somme



        ############################# spectrak spread #############################
        
        print("3.3) Spectral spread")
            
        spectralSpread = np.zeros(len(time))
        # spectralSpread : écart-type de la distribution spectrale pour chaque unité temporelle

        for i in np.arange(len(time)):
            
            spectralSpread[i] = np.sum((freq - spectralCentroid[i])**2 * np.abs(fourierVect[:,i]))
            somme = np.sum(np.abs(fourierVect[:,i]))
            
            if (somme < 1e-4):
                spectralSpread[i] =0
            else:      
                spectralSpread[i] = spectralSpread[i] / somme

        spectralSpread = spectralSpread**0.5
        
        
        
        ############################# spectrak skewness & kurtosis #############################
        
        print("3.4) Spectral skewness and kurtosis")
            
        spectralSkewness = np.zeros(len(time))
        # spectralSkewness = 0 : symmetric distribution of the spectrum
        # spectralSkewness < 0 : asymmetric distribution. More energy at frequencies lower than the mean frequency
        # spectralSkewness > 0 : More energy at higher frequencies
        
        
        spectralKurtosis = np.zeros(len(time))
        # spectralKurtosis = 3 : normal distribution (gaussian)
        # spectralSkewness < 3 : a flatter distribution
        # spectralSkewness > 3 : a peaker distribution
        
        for i in np.arange(len(time)):
            
            spectralSkewness[i] = np.sum((freq - spectralCentroid[i])**3 * np.abs(fourierVect[:,i]))
            spectralKurtosis[i] = np.sum((freq - spectralCentroid[i])**4 * np.abs(fourierVect[:,i]))
            somme = np.sum(np.abs(fourierVect[:,i]))
            
            if (somme < 1e-4):
                spectralSkewness[i] = 0
                spectralKurtosis[i] = 0
            else:         
                spectralSkewness[i] = spectralSkewness[i] / (somme * spectralSpread[i]**3)
                spectralKurtosis[i] = spectralKurtosis[i] / (somme * spectralSpread[i]**4)
        

        
        ############################# MFCC coefficients #############################
        
        print("3.5) MFCC coefficients")
            
        melFreq, filtreTriang = self.melMesh(nfreq = len(freq), Nmesh = 28)
        cepstre =  np.zeros((fourierVect.shape[1], filtreTriang.shape[0])) 
        
        # boucle sur les fenetres temporelles
        for j in np.arange(fourierVect.shape[1]):
            intensity = np.abs(fourierVect[:,j])**2 / taille
            
            # boucle sur les différents filtres triangulaires
            for k in np.arange(filtreTriang.shape[0]):
                # somme sur les différentes fréquences
                cepstre[j,k] = np.sum(intensity*filtreTriang[k,:])
            
            if (np.amax(cepstre[j,:]) > 0.):
                cepstre[j, :] = np.log(cepstre[j,:])
            fftpack.dct(cepstre[j, :], norm = 'ortho', overwrite_x = True)
         
#        print("MFCC coefficients 1ere tram : ")
#        print(cepstre[0, :])
#        
#        print("************************")
#        
#        print("MFCC coefficients last tram : ")
#        print(cepstre[cepstre.shape[0]-1, :])
        
        ############################# figures #############################
        
#        plt.figure()
#        plt.pcolormesh(time, freq, np.abs(fourierVect))
#        plt.axis([0, self.duration, 0, 5000])
#        plt.title('Spectrogramm (STFT Magnitude)')
#        plt.ylabel('Frequency [Hz]')
#        plt.xlabel('Time [sec]')
#        plt.colorbar()
#        
#        plt.figure()
#        plt.plot(time, loudness)
#        plt.ylabel('Loudness')
#        plt.xlabel('Time [sec]')
#        
#        plt.figure()
#        plt.plot(time, spectralCentroid)
#        plt.ylabel('Spectral Centroid [Hz]')
#        plt.xlabel('Time [sec]')
#        
#        
#        plt.figure()
#        plt.plot(time, spectralSpread)
#        plt.ylabel('Spectral Spread [Hz]')
#        plt.xlabel('Time [sec]')
#        
#        
#        plt.figure()
#        plt.plot(time, spectralSkewness)
#        plt.ylabel('Spectral Skewness')
#        plt.xlabel('Time [sec]')
#        
#        
#        plt.figure()
#        plt.plot(time, spectralKurtosis)
#        plt.ylabel('Spectral Kurtosis')
#        plt.xlabel('Time [sec]')
#        
#        plt.figure()
#        plt.pcolormesh(np.arange(filtreTriang.shape[0]), time, cepstre, cmap = 'RdBu')
#        plt.colorbar()
##        plt.axis([0, cepstre.shape[1], 0, 5000])
#        plt.ylabel('Time ')
#        plt.xlabel('Mel Freq')
        
#        for i in np.arange(len(melFreq)):
#            print(melFreq[i])
        
        
        ############################# return values #############################
        
#        return bpm, spectralCentroid, spectralSpread, spectralSkewness, spectralKurtosis, cepstre
        return spectralCentroid, spectralSpread, spectralSkewness, spectralKurtosis, cepstre



    def melMesh(self, nfreq, Nmesh = 18):
        """ Filtre triangulaire à l'échelle Mel """
        
        highFreq = self.frequency/2
        lowFreq = 0
        
        minMel = freq2mel(lowFreq)
        maxMel = freq2mel(highFreq)
        
        melVect = np.linspace(minMel, maxMel, num = Nmesh)
        melFreq = mel2freq(melVect)
        melFreq = np.floor(2*(nfreq - 1)*melFreq / self.frequency)
        
        melFilters = np.zeros((Nmesh-2, nfreq))
        
        for i in np.arange(1, Nmesh - 1):
            for j in np.arange(nfreq):
                if ((j >= melFreq[i-1]) and (j <= melFreq[i])):
                    melFilters[i-1,j] = (j - melFreq[i-1]) / (melFreq[i] - melFreq[i-1])
                    
                elif ((j > melFreq[i]) and (j <= melFreq[i+1])):
                    melFilters[i-1,j] = ( melFreq[i+1] - j) / (melFreq[i+1] - melFreq[i])
        
        
        
#        plt.figure()
#        for i in np.arange(melFilters.shape[0]):
#            plt.plot(melFilters[i,:])
#            
#        plt.xlabel("frequency [Hz]")
        
        melFreq = mel2freq(melVect)
        
        return melFreq, melFilters



    def Attaque(self):
        seuil = np.linspace(0.1,1, num = 10)
        
        Emax = np.amax(self.ampliEnveloppe)
#        print("amplitude maxi de l'enveloppe : ", Emax)
        time = []
        effort = []
        j = 0
        Nbre = 0
        
        
        for i in np.arange(len(seuil)):
            seuilEnv = seuil[i]*Emax
            
            isInf = True
            
            while (isInf and j < len(self.ampliEnveloppe) - 1):
               if (self.ampliEnveloppe[j] >= seuilEnv):
#                   print("echantillon ", j)
#                   print("valeur enveloppe", self.ampliEnveloppe[j])
#                   print("valeur du seuil : ", seuilEnv)
                   time.append(j)
                   Nbre += 1
                   j += 1
                   isInf = False
                   if (Nbre >= 2):
                       effort.append(time[Nbre-1] - time[Nbre - 2])    
               else:
                   j += 1
                
#        print("temps d'intérêt")        
#        print(time)
#        
#        print("effort")        
#        print(effort)
        
        meanEffort = np.sum(effort)/len(effort)
        alpha = 2
        indEffortFaible = []
        
        
       
        for i in np.arange(len(effort)):
            if (effort[i] <= alpha * meanEffort):
                indEffortFaible.append(i)
        
#        print("seuil à ne pas dépasser")        
#        print( alpha * meanEffort)
#        
#        print("effort faible")        
#        print( indEffortFaible)
        
        startAttack = time[indEffortFaible[0]]
        endAttack = time[indEffortFaible[-1]]
        
#        print ('Debut attaque : ', startAttack/self.frequency, 's')
#        print ('Fin attaque : ', endAttack/self.frequency, 's')
            
        return startAttack, endAttack



    def rapportAmp(self):
        print('amplitude max', np.amax(self.ampliEnveloppe))
        print('amplitude min', np.amin(self.ampliEnveloppe))
        fin = len(self.ampliEnveloppe) - 2
        return np.amin(self.ampliEnveloppe[1:fin])/np.amax(self.ampliEnveloppe[1:fin])
    

    def tableDonnees(self, fichier):
        
        print("calcul descripteurs")
        
        print("1. Attaque")
        startAttack, endAttack = self.Attaque()
        duree = (endAttack - startAttack)/self.frequency
        print("2. Centre de gravité temporel")
        gravity = self.temporalCentroid()
        print("3. Descripteurs spectraux")
#        bpm, spectralCentroid, spectralSpread, spectralSkewness, spectralKurtosis, cepstre = self.TFCTSignal()
        spectralCentroid, spectralSpread, spectralSkewness, spectralKurtosis, cepstre = self.TFCTSignal()
        
        taille = len(spectralCentroid)
        debut = int(np.round(30*taille/100))
        fin = taille - debut
        print(taille, debut, fin)
        
        print("4. Récupération des descripteurs dans des variables de type string")
        descript1 = ";" + str(duree) + ";"
#        descript2 = str(bpm) + ";"
        descript3 = str(gravity) + ";"
        descript4 = str(np.mean(spectralCentroid[debut:fin])) + ";"
        del spectralCentroid
        descript5 = str(np.mean(spectralSpread[debut:fin])) + ";"
        del spectralSpread
        descript6 = str(np.mean(spectralSkewness[debut:fin])) + ";"
        del spectralSkewness
        descript7 = str(np.mean(spectralKurtosis[debut:fin])) + ";"
        del spectralKurtosis
        descript8 = []
        
        for i in np.arange(13):
            string = str(np.mean(cepstre[:,i][debut:fin])) + ";"
            descript8.append(string)
        
        del cepstre
        
        print("5. Enregistrement de ces descripteurs dans un fichier")
        with open(fichier, 'a') as file:
            file.write("\n")
#            file.write(self.nom + descript1 + descript3 + descript2 + descript4 + descript5 + descript6 + 
#                       descript7 + descript8[0] + descript8[1] + descript8[2] + descript8[3] + descript8[4] +
#                       descript8[5] + descript8[6] + descript8[7] + descript8[8] + descript8[9] + 
#                       descript8[10] + descript8[11]  + descript8[12])
            file.write(self.nom + descript1 + descript3 + descript4 + descript5 + descript6 + 
                       descript7 + descript8[0] + descript8[1] + descript8[2] + descript8[3] + descript8[4] +
                       descript8[5] + descript8[6] + descript8[7] + descript8[8] + descript8[9] + 
                       descript8[10] + descript8[11]  + descript8[12])





