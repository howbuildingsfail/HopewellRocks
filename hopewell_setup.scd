

//TODO: figure out how to be able to run this whole file!



// http://sccode.org/1-4Tq Dirty FM Shuffle
(
SynthDef(\fmshuffle, {|out, freq, gate = 1, amp = 1, carFreq = 1000, modFreq = 100, modAmount = 2000, clipAmount = 0.1, pan |
	var modEnv = EnvGen.ar(Env.adsr(0.5, 0.5, 0.7, 0.1, peakLevel: modAmount), gate);
	var mod = SinOsc.ar(modFreq) * modEnv;
	var car = SinOsc.ar(freq + mod);
	var ampEnv = EnvGen.ar(Env.adsr(0.1, 0.3, 0.7, 0.2, peakLevel: amp), gate, doneAction: 2);
	var clip = clipAmount * 500;
	var sound = (car * ampEnv * clip).clip(-0.7, 0.7) * 0.1;
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan))
}).add
);


//http://sccode.org/1-4Uz
	// SynthDef
	//SynthDef("formantVoice", { arg
	SynthDef("fovo", { arg
		freqs = #[ 400, 750, 2400, 2600, 2900 ],
		amps = #[ 1, 0.28, 0.08, 0.1, 0.01 ],
		qs = #[ 0.1, 0.1, 0.04, 0.04, 0.04 ],
		lag = 0.5,
		vibratoSpeed = 6,
		vibratoDepth = 4,
		freq = 220,
		gate = 1;

		var vibrato, in, env, snd;

		vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
		in = Saw.ar(Lag.kr(freq + vibrato, 0.2));
		env = EnvGen.kr(Env.asr(1), gate, doneAction: 2);
		snd = Mix.new(BBandPass.ar(in, Lag.kr(freqs, lag), Lag.kr(qs, lag)) * Lag.kr(amps, lag)).dup;

		Out.ar(0, snd * env);

	}).add;



(
SynthDef("plucking", {arg amp = 0.1, freq = 440, decay = 5, dampen = 0.1;

var env, snd;
env = Env.linen(0, decay, 0).kr(doneAction: 2);
snd = Pluck.ar(
        in: WhiteNoise.ar(amp),
        trig: Impulse.kr(0),
        maxdelaytime: 0.1,
        delaytime: freq.reciprocal,
        decaytime: decay,
        coef: dampen);
    Out.ar(0, [snd, snd]);
}).add;
)



//This works! Based on ideas at the link, but adapted for tidal
// https://composerprogrammer.com/teaching/supercollider/sctutorial/11.1%20Physical%20Modelling.html

(
SynthDef(\ksg, { | out, freq=300, pan = 1, kRand = 9.9, delayTime = 8, noiseType=2 |
	var x, y, env;
	env = Env.new(#[1, 6, 0],#[20, 0.1]);

	// A simple exciter x, with some randomness.
	x = Decay.ar(Impulse.ar(0, 0, kRand), 0.1+kRand, WhiteNoise.ar);
 	x = CombL.ar(x, 0.05, freq.reciprocal, delayTime, EnvGen.ar(env, doneAction:2));
	x = Pan2.ar(x, pan);
	//Out.ar(0, LeakDC.ar(x));
    OffsetOut.ar(out, DirtPan.ar(x, ~dirt.numChannels, pan))
}).add
);

/////////////////////////////////////////////////////////////////////////////////////////////
//see scsythsanddrums.scd for originals:!
(
SynthDef("kick", {arg out = 0, amp = 0.5, freq = 120, glissf = 0.019, att = 0.01, rel = 0.55, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: freq,
		end: freq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
}).add;
)


(
SynthDef("snare", {arg out = 0, amp = 0.1, freq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: freq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;
)

(
SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;
)


//We can just use superdirt.Start if we are using the LATEST version - otherwise
//we have to use the alternative start, below (which doesn't seem to work)
SuperDirt.start;

