(
// DTMF (Dual-Tone Multi-Frequency) Phone Dialer
// Maps phone keys to their frequency pairs

// Frequency table for phone keypad
~tbl = IdentityDictionary[
	$1 -> [697, 1209],
	$2 -> [770, 1209],
	$3 -> [852, 1209],
	$4 -> [697, 1336],
	$5 -> [770, 1336],
	$6 -> [852, 1336],
	$7 -> [697, 1477],
	$8 -> [770, 1477],
	$9 -> [852, 1477],
	$* -> [697, 1633],
	$0 -> [770, 1633],
	$# -> [852, 1633],
	$A -> [941, 1209],
	$B -> [941, 1336],
	$C -> [941, 1477],
	$D -> [941, 1633]
];

// SynthDef for DTMF tones with DUSTY ANALOG TRANSMISSION effects
SynthDef(\dtmf, {|freq=#[770, 1633], out=0, amp=1, gate=1|
	var beep, env, beepgate;
	var dusty, crackle, hiss, noiseLevel;
	var dropoutZone, beepCrackleMix, finalBeep;

	// ========== CORE DTMF SIGNAL ==========
	beep = SinOsc.ar(freq*0.25, 0, amp).sum;

	// DISTORT THE HELL OUT OF IT
    beep = (beep * 1.15).clip2(0.9);  // aggressive clipping
    beep = beep.fold2(0.66);  // fold for more harmonic distortion
    beep = beep.round(0.05);  // bit crush - cheap digital
    //beep = (beep * 5).tanh*0.2;  // soft saturation on top

	beepgate = LFPulse.kr(LFNoise0.kr(0.2).range(1, 4), 0,
        LFNoise0.kr(0.3).range(0.7, 0.95));  // mostly open, occasional drops

	// ========== ANALOG TRANSMISSION DEGRADATION ==========

	// VINYL CRACKLE - random pops and clicks
	crackle = Dust.ar(60) * 3 * LFNoise1.kr(0.2).range(0.3, 1);  // adjust 60 for density
	crackle = LPF.ar(crackle, 3600);  // filter to make it darker/lower pitched

	// TAPE HISS - constant background noise
	hiss = PinkNoise.ar(0.08) * LFNoise1.kr(2).range(0.6, 1);  // adjust 0.08 for hiss level

	// ========== ACTRESS-STYLE BEEP DROPOUT ==========
	// Slow LFO: are we in a dropout zone? (affects several beeps in a row)
	dropoutZone = LFNoise1.kr(0.15).range(0, 1);  // slow drift, 0.15 Hz
	dropoutZone = (dropoutZone > 0.65);  // threshold: 35% of time in dropout, HARD CUT (no lag)
	// Sample-and-hold on beep boundaries to avoid cutting mid-beep
	//dropoutZone = Latch.kr(dropoutZone, 1 - beepgate);  // latch when beepgate goes low (between beeps)

	// Fast LFO: when in dropout, how much beep vs pure crackle?
	beepCrackleMix = LFNoise1.kr(2).range(0, 1);  // faster modulation, 2 Hz

	// Apply the dropout effect:
	// When dropoutZone = 0 (normal): full beep
	// When dropoutZone = 1 (dropout): blend between some beep and just crackle
	finalBeep = beep * (1 - (dropoutZone * beepCrackleMix.linlin(0, 1, 0.3, 0.95)));

	// Boost crackle to suggest the missing beep
	crackle = crackle * (1 + (dropoutZone * 2.5));  // extra crackle during dropouts

	// ========== MIX IT ALL TOGETHER ==========
	// Crackle and hiss are constant but get BOOSTED when beeps happen
	noiseLevel = beepgate.linlin(0, 1, 0.12, 1.0);  // quiet (0.12) in gaps, full (1.0) during beeps
	dusty = (finalBeep * beepgate) + ((crackle + hiss) * noiseLevel);  // use finalBeep (with dropouts)

	env = EnvGen.ar(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(dusty * env * amp));
}).add;

Routine({
    s.sync;
    
    // All keypad keys including special chars
    ~allKeys = [$1, $2, $3, $4, $5, $6, $7, $8, $9, $*, $0, $#, $A, $B, $C, $D];
    ~pos = rrand(0, ~allKeys.size - 1);  // start at random position
    
    Pbind(
        \instrument, \dtmf,
        
        // STEADY RHYTHM with variations
        \dur, Pseq([
            // Main pattern: note (0.25s) + pause (0.35s) = 0.6s total
            Pwrand([
                0.6,                              // normal: play then pause (85%)
                Pseq([0.15, 0.1, 0.15, 0.2], 1), // RARE: two quick notes filling gaps (5%)
                1.2                               // skip a beat (10%)
            ], [0.85, 0.05, 0.1], 1)
        ], inf).flatten + Pwhite(-0.015, 0.015, inf),  // slight human timing drift (±15ms)
        
        \sustain, Pif(Pfunc({ |ev| ev[\dur] < 0.3 }), 0.15, 0.25) + Pwhite(-0.01, 0.01, inf),  // tiny sustain variation
        \amp, Pwhite(0.18, 0.28, inf),
        
        // SEQUENTIAL DIALING with variations
        \freq, Pfunc({
            var key;
            
            // Most of the time: move forward sequentially
            // Sometimes: restart, jump, or go backwards
            ~pos = case
                { 0.75.coin } { (~pos + 1).wrap(0, ~allKeys.size - 1) }  // forward (75%)
                { 0.10.coin } { rrand(0, ~allKeys.size - 1) }            // jump random (10%)
                { 0.08.coin } { 0 }                                       // restart from beginning (8%)
                { (~pos - 1).wrap(0, ~allKeys.size - 1) };               // backwards (7%)
            
            key = ~allKeys[~pos];
            ~tbl[key]
        })
    ).play;
    
    "Voodoo dialer running...".postln;
}).play;
)