// Voodoo - Test Version
// Inspired by Actress - Voodoo Posse, Chronic Illusion
// Simplified for norns dronecaster

(
x = {
    arg hz=55, amp=0.3;
    var noise, bass, beep, beep2, sig;
    var beepTrig, beepEnv, dtmfLow, dtmfHigh, dtmfPairs, pairIndex;
    var phraseLen, phraseTrig, beepInPhrase, phraseGate;

    // A. Background noise bed
    noise = PinkNoise.ar(0.12);
    noise = BPF.ar(noise,
        LFNoise1.kr(0.08).range(500, 1800),
        0.4
    );
    noise = noise * LFNoise1.kr(0.12).range(0.5, 0.8);

    // B. Bass drone - multiple harmonics for body
    bass = SinOsc.ar(hz * [1, 1.004], mul: 0.7);
    bass = bass + SinOsc.ar(hz * 1.5 * [1, 0.996], mul: 0.35);
    bass = bass + SinOsc.ar(hz * 0.5, mul: 0.2);
    bass = Mix.ar(bass);
    bass = bass * LFNoise1.kr(0.06).range(0.8, 1.0);
    bass = (bass * 1.2).tanh;
    bass = LPF.ar(bass, 300);

    // C. DTMF beeps - sequences of 1-6 beeps, then silence
    // DTMF phone keypad pairs: keys 1,2,4,5,8,9,0,*,#
    dtmfPairs = [
        [697, 1209],   // 1
        [770, 1209],   // 2
        [697, 1336],   // 4
        [770, 1336],   // 5
        [770, 1477],   // 8
        [852, 1477],   // 9
        [770, 1633],   // 0
        [697, 1633],   // *
        [852, 1633]    // #
    ];

    // Phrase trigger - starts a new sequence every 4-8 seconds
    phraseTrig = Impulse.kr(LFNoise0.kr(0.08).range(0.15, 0.25));

    // How many beeps in this phrase? (1-6)
    phraseLen = Demand.kr(phraseTrig, 0, Drand([1,2,3,4,5,6], inf));

    // Individual beep trigger - 4 Hz = 0.25s per beep
    beepTrig = Impulse.kr(3);

    // Counter: which beep are we on in the current phrase?
    beepInPhrase = PulseCount.kr(beepTrig);
    beepInPhrase = (beepInPhrase - 1) % 16;  // reset every 16 beats

    // Reset counter at start of new phrase
    beepInPhrase = Latch.kr(beepInPhrase, phraseTrig) * 0 + beepInPhrase;

    // Gate: only play if we're within the phrase length
    phraseGate = (beepInPhrase < phraseLen);

    // Only trigger envelope when we're in a phrase
    // Linen: attack, sustain, release - flat phone beep sound
    beepEnv = EnvGen.ar(Env.linen(0.005, 0.18, 0.02), beepTrig * phraseGate);

    // Pick random DTMF pair on each beep
    pairIndex = Demand.kr(beepTrig, 0, Drand([5,6,7,8], inf));
    dtmfLow = Select.kr(pairIndex, dtmfPairs.collect(_[0])) * 0.25;
    dtmfHigh = Select.kr(pairIndex, dtmfPairs.collect(_[1])) * 0.25;

    // Core DTMF signal
    beep = SinOsc.ar(dtmfLow) + SinOsc.ar(dtmfHigh);
	beep2 = (beep * 1.05).clip2(0.95);  // aggressive clipping
    beep2 = beep.fold2(01.0);  // fold for more harmonic distortion
    beep2 = beep.round(0.05);  // bit crush - cheap digital
    beep = (beep *0.8) + (beep2*0.2);
    // Apply envelope and gate
    beep = beep * beepEnv * phraseGate * 0.5;

    // Mix all layers
    sig = (noise * 0.2) + (bass * 0.75) + (beep * 0.3);

    // Final glue
    sig = (sig * 1.1).tanh;
    sig = Limiter.ar(sig, 0.9);

    (sig * amp).dup;
}.play;
)

// Controls:
// x.set(\hz, 82);   // Change pitch
// x.set(\amp, 0.5); // Change volume
// x.free;           // Stop
