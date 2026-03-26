// Voodoo
// Inspired by Actress - Voodoo Posse, Chronic Illusion
// A fog of noise, unstable bass drone, and piercing beeps

{
    arg hz=55, amp=0.3;
    var noise, bass, beep, sig;
    var noiseFreq, beepTrig, beepEnv, beepPitch;
    
    // A. Background noise bed - the "air"
    // Subtle, filtered noise that gives texture
    noise = PinkNoise.ar(0.08);
    noise = BPF.ar(noise, 
        LFNoise1.kr(0.1).range(500, 2000),  // slow filter movement
        0.5  // moderate bandwidth
    );
    noise = noise * LFNoise1.kr(0.15).range(0.4, 0.7);  // slow amplitude wobble
    
    // B. Bass/chord drone - harmonic anchor
    // Two slightly detuned oscillators for that "drunk power supply" feel
    bass = SinOsc.ar(hz * [1, 1.003], mul: 0.4);  // root with slight detune
    bass = bass + SinOsc.ar(hz * 1.5 * [1, 0.997], mul: 0.15);  // add a fifth, also detuned
    bass = Mix.ar(bass);
    // Very slow breathing movement
    bass = bass * LFNoise1.kr(0.08).range(0.7, 1.0);
    // Soft low-pass to blur it
    bass = LPF.ar(bass, 200);
    
    // C. Distorted "phone beep" melody
    // Obsessive, stiff, piercing tone
    beepTrig = Impulse.kr(LFNoise0.kr(0.2).range(0.5, 2));  // irregular beeps
    beepEnv = EnvGen.ar(Env.perc(0.001, 0.05), beepTrig);
    beepPitch = TChoose.kr(beepTrig, [1000, 1200, 900, 1100]);  // limited pitch choices
    beep = SinOsc.ar(beepPitch);
    beep = BPF.ar(beep, 1200, 0.3);  // narrow band-pass
    beep = (beep * 8).clip2(0.6);  // hard distortion
    beep = beep * beepEnv * 0.2;
    
    // Mix everything
    sig = (noise * 0.3) + (bass * 0.6) + (beep * 0.4);
    
    // Gentle final limiting
    sig = Limiter.ar(sig, 0.95);
    
    (sig * amp).dup;
}
