// Amplitude-Shift Keying (ASK) Synthesis - Drone/Texture
// Based on: https://nathan.ho.name/posts/dm-synthesis/
//
// ASK modulates the amplitude of a carrier sine wave using a discrete signal
// with a fixed number of possible values, creating interesting textural drones

(
x = {
    arg carrier=110,           // carrier frequency in Hz
    sigRate=4,                // signaling rate (bits per second)
    numLevels=16,              // number of discrete amplitude levels
    amp=0.3,
    smoothing=0.1,           // smoothing between amplitude transitions
    minAmp=0.3,               // minimum amplitude level
    maxAmp=1.3;               // maximum amplitude level > imagine both of these to be amp controlled

    var sig, sig2, ampSig;
    var trig, randomLevel;
	var crackle, hiss;

    // Generate random discrete amplitude levels at the signaling rate
    trig = Impulse.kr(sigRate);

    // Generate random integers from 0 to numLevels-1
    randomLevel = Demand.kr(trig, 0, Diwhite(0, numLevels-1));

    // Map the discrete levels to amplitude range
    ampSig = LinLin.kr(randomLevel, 0, numLevels-1, minAmp, maxAmp);

    // Optional smoothing to soften transitions
    ampSig = Lag.kr(ampSig, smoothing);

    // Generate carrier sine wave
	sig = SinOsc.ar([carrier, carrier*2.01]).sum; //detuned signal
	sig2 = SinOsc.ar(carrier);
	sig = LPF.ar(sig, 160); //filter out higher freqs
	sig = (sig2 * 0.9) + (sig*0.3); //mix between detuned and normal signal > AMP control

    // Apply amplitude modulation
    sig = sig * ampSig;

	sig = BPF.ar(sig, 250, 0.3);
	sig = sig.clip(-0.3, 0.6);
	sig = (sig * 16).round / 64; //divide by 32 is tame, down to 1 gets strong this one is going to be key for Hz control, it sounds higher pitched over that range. where /0.1 is at 2000hz, and / 64 at 33hz
	sig = BPF.ar(sig, 200, 0.3)*5;

	sig = (sig * 1.15).clip2(0.66);  // aggressive clipping
	sig = (sig * 5).tanh*0.2;
    sig = sig.fold2(0.8);  // fold for more harmonic distortion
    sig = sig.round(0.01);  // bit crush - cheap digital

    // Overall amplitude control
	crackle = Dust.ar(60*ampSig) * 3 * LFNoise1.kr(0.2).range(0.3, 1);  // adjust 60 for density
	crackle = LPF.ar(crackle, 1400);  // filter to make it darker/lower pitched
	hiss = PinkNoise.ar(0.035) * ampSig;  //
	sig = sig * amp + (crackle*0.15) + hiss; //crackle also needs to get lower at lower Hz input - about 0.1 at 33hz

    sig.dup;
}.play;
)

// Controls:
// x.set(\carrier, 330);       // change carrier frequency
// x.set(\sigRate, 12);        // faster modulation
// x.set(\sigRate, 2);         // slower modulation
// x.set(\numLevels, 4);       // fewer levels (more periodic)
// x.set(\numLevels, 16);      // more levels (more random)
// x.set(\smoothing, 0.1);     // smoother transitions
// x.set(\smoothing, 0.001);   // harsher transitions
// x.set(\amp, 0.5);           // change volume
// x.free;                     // stop

// Try these presets:
// x.set(\carrier, 110, \sigRate, 3, \numLevels, 6, \smoothing, 0.08);   // slow dreamy
// x.set(\carrier, 440, \sigRate, 30, \numLevels, 16, \smoothing, 0.001); // fast glitchy
// x.set(\carrier, 55, \sigRate, 2, \numLevels, 4, \smoothing, 0.05);    // deep slow
