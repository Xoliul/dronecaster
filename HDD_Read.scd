/*  HDD Read Crackle — single playable file
    Paste into SC, evaluate.
    Start:   ~hdd.play
    Stop:    ~hdd.stop
    Tweak:   ~hdd.set(\rate, 2.0, \density, 0.6, \thump, 0.5, \hiss, 0.25)
*/

s.waitForBoot({

	SynthDef(\hddRead, { |out=0, amp=0.25, rate=1.6, density=0.55, thump=0.55, hiss=0.6, pan=0|
		var trig, burstEnv, pauseGate, burstTrig;
		var clicks, crackle, lowCrackle, thumps, air, mech, sig;

		// Burst timing: random pauses + clusters
		// A slow "should we be active right now?" gate
		pauseGate = Demand.kr(Impulse.kr(rate * 0.35), 0, Dwrand([0, 1], [1 - density, density], inf));
		// Bursty trigger stream when gate is open
		trig = Dust2.kr(rate * 40 * (pauseGate + 0.02)); // small base so it never fully dies
		// A short envelope per click cluster
		burstEnv = Decay2.kr(trig, 0.001, TRand.kr(0.01, 0.07, trig));

		// Click layer: sharp, low-ish crackles (not too bright)
		clicks = HPF.ar(WhiteNoise.ar(1.0), 120) * burstEnv;
		clicks = BPF.ar(clicks, TRand.kr(180, 300, trig), 0.2);

		// Crackle body: low-frequency crackle / chatter
		crackle = Crackle.ar(TRand.kr(1.4, 1.95, trig)) * (burstEnv * 0.2);
		lowCrackle = LPF.ar(crackle, 900);

		// Thumpy head-seek / motor ticks (subby "tck")
		burstTrig = Trig1.kr(trig, 0.004);
		thumps = SinOsc.ar(
			[120,160],
			0,
			EnvGen.ar(Env.perc(0.001, TRand.kr(0.02, 0.06, burstTrig)), burstTrig) * thump
		).sum;
		thumps = (thumps + (LPF.ar(WhiteNoise.ar(0.4), 120) *
			EnvGen.ar(Env.perc(0.001, 0.05), burstTrig) * (thump * 0.35)));
		thumps = ((thumps.clip2(0.9).fold2(0.5).round(0.02))*5).tanh * 0.2;
		thumps = LPF.ar(thumps,800,1,0);

		// Air / hiss (subtle) + slight mechanical tone wobble
		air = HPF.ar(WhiteNoise.ar(hiss), 1400) * (0.3 + (burstEnv * 0.7))*0.2;
		mech = SinOsc.ar( TRand.kr(18, 28, trig), 0, 0.02) * (0.2 + burstEnv);

		sig = thumps;//(clicks * 0.1) + (lowCrackle * 0.2) + thumps + air + mech;

		// Slight saturation / compression-like glue
		sig = tanh(sig * 2.2) * 0.6;

		// Keep it mostly mono, with tiny movement
		sig = Pan2.ar(sig, pan + LFNoise2.kr(0.2).range(-0.15, 0.15))*2.0;

		Out.ar(out, sig * amp);
	}).add;

	s.sync;

	// Convenience object
	~hdd = Synth(\hddRead, [
		\amp, 0.28,
		\rate, 1.6,     // overall activity speed
		\density, 0.55, // probability of bursts vs pauses
		\thump, 0.55,
		\hiss, 0.22,
		\pan, 0
	]);

	"Ready: ~hdd is running. Use ~hdd.set(...) or ~hdd.free".postln;
});
