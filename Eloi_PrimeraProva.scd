


(
ServerQuit.removeAll;
ServerBoot.removeAll;
ServerTree.removeAll;
Buffer.freeAll;

s.waitForBoot({

t = TempoClock.new(130/60).permanent_(true);

s.sync;


SynthDef(\kick2, {
	arg freqGreu=167;
    var snd;
    snd = DC.ar(0);
    snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1320) * Env.perc(0.003, 0.03).ar * 0.5);
    snd = snd + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(freqGreu, 52, 0.04)) * Env.perc(0.0005, 0.3).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;

SynthDef(\noise1, {
	arg amp, rel=0.1, pan, filtre=1000;
	var sig, env;
	sig = WhiteNoise.ar(amp);
	env = Env.perc(0.01, rel).kr(2);
	sig = HPF.ar(sig, filtre);
	sig = sig * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig)
}).add;

SynthDef(\crackle1, {
	arg amp, chaos=1.5, pan, filtre=1000;
	var sig, env;
	sig = Crackle.ar(chaos, amp);
	sig = HPF.ar(sig, filtre);
	Out.ar(0, sig)
}).add;

SynthDef(\click1, {
	arg freq=100, amp=1;
	var sig, env;
	env = Env.perc(0.01, 0.25).kr(2);
	sig = SinOsc.ar(freq,0, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;



Pbindef.all.do(_.clear);

s.sync;


s.bind({

Pbindef(\bombo1,
	\instrument, \kick2,
	\dur,
		Pwrand([

			Pn(
				Plazy({
					Pshuf(
						(1/4!4)
						++
						(1/4!4)
						++
						(1/2!2)
						++
						(1/2!2)
					    ++
						1, 2)
				 }), 2),

			Pn(
				Plazy({
					Pshuf(
						(1/8!8)
						++
						(1/4!4)
						++
						(1/4!4)
						++
						(1/2!2)
					    ++
						1, 2)
				 }), 1)
		],
		[1, 0.00], inf).trace, //mai sona el segon


		\freq, Pn( Plazy({ Pshuf( (1!10) ++ (\!3), 1) }), inf),
		\freqGreu, Pn( Plazy({ Pshuf( (167!10) ++ (400!3), 1) }), inf),



		\amp, Pn( Plazy({ Pshuf( (0.5!4) ++ (0.35!9), 2) }), inf),
).play(t);

Pbindef(\noise,
		\instrument, \noise1,
		\dur, Prand([1/4,1/2], inf),
		\rel, Pn( Plazy({ Pshuf( [0.05, 0.05, 0.1, 0.1, 0.25] /4, 2) }), inf),
		\amp, 0.25,
		\pan, Pwhite(-1, 1, inf),
		\filtre,  Pseq([
			Pseq( (100!30), 1),
			Pexprand(100, 8000, 20)
		], inf)
).play(t);

Pbindef(\clickSin,
		\instrument, \click1,
		\dur, 1,
		\freq, Pseq([800, 500, 500, 500, 800, 500, 500, 500, 500] , inf),
		\amp, Pseq( Array.geom(5, 0.1, 0.9), inf)
).play(t);

Pmono(\crackle1,
		\dur, 1/8,
		\chaos, Pwhite(1.5, 1.95, inf),
		\filtre, Pwhite(5000, 12000, inf),
		\amp, Pkey(\filtre).linlin(5000, 12000, 0.01, 0.95) /4
).play(t);

});


})

)


Pbindef(\noise).play

s.quit

(
s.bind({
Pbindef(\noise25,
		\instrument, \noise1,
		#[dur, freq, rel, amp, pan, filtre], Prand([

			Pseq([

				Ptuple([ // patro 4x4

					Pseq([   //dur
						1/2, 1/4, 1/4,
						1/4, 1/2, 1/4,
						1/4, 1/2, 1/4,
						1/4, 1/4, 1/2,
					],1),

					Pseq([   // freq
						1, 1, 1,
						\, 1, 1,
						\, 1, 1,
						1, 1, 1,
					], 1),

					Pwrand([0.02, 0.05, 0.1], [0.5, 0.25, 0.25], 12), // rel

					Pseq([ 0.25, Pwhite(0.05, 0.15, 2) ], 4), // amp

					Pseq([ 0, -1, 1], 12), // Pan2

					Pwhite(100, 10000, 12)
				    ], 1),


				Ptuple([   // patro 5x4

					Pseq([   //dur
						1/2, 1/4, 1/4,
						1/4, 1/4, 1/2,
						1/4, 1/4, 1/2,
						1/4, 1/2, 1/4,
						1/4, 1/4, 1/2,

					],1),

					Pseq([   // freq
						1, 1, 1,
						1, 1, 1,
						\, 1, 1,
						\, 1, 1,
						1, 1, 1

					], 1),

					Pwrand([0.02, 0.05, 0.1], [0.5, 0.25, 0.25], 15), // rel

					Pseq([ 0.25, Pwhite(0.05, 0.15, 2) ], 5), // amp

					Pseq([ 0, -1, 1], 15), // Pan2

					Pshuf( (100!15), 1)

				    ],1),

			], 1),



			Pseq([

				Ptuple([ // patro 4x4

					Pseq([   //dur
						1/2, 1/4, 1/4,
						1/2, 1/2,
						1/4, 1/2, 1/4,
						1/4, 1/4, 1/4, 1/4,
					],1),

					Pseq([   // freq
						1, 1, 1,
						\, 1,
						\, 1, 1,
						1, 1, 1, 1
					], 1),

					Pwrand([0.02, 0.05, 0.1], [0.5, 0.25, 0.25], 12), // rel

					Pseq([
						0.25, Pwhite(0.05, 0.15, 2),
						0.25, Pwhite(0.05, 0.15, 1),
						0.25, Pwhite(0.05, 0.15, 2),
						0.25, Pwhite(0.05, 0.15, 3),
					],1), // amp

					Pseq([ 0, -1, 1, 0, -1, 0, -1, 1, 0, -1, 1, -1], 1), // Pan2

					Pwhite(100, 10000, 12)

					],1),

				Ptuple([ // patro 5x4

					Pseq([   //dur
						1/2, 1/4, 1/4,
						1/2, 1/2,
						1/4, 1/4, 1/2,
						1/4, 1/2, 1/4,
						1/4, 1/4, 1/4, 1/4,

					],1),

					Pseq([   // freq
						1, 1, 1,
						1, 1,
						1, 1, \,
						\, 1, 1,
						1, 1, 1, 1

					], 1),

					Pwrand([0.02, 0.05, 0.1], [0.5, 0.25, 0.25], 15), // rel

					Pseq([
						0.25, Pwhite(0.05, 0.15, 2),
						0.25, Pwhite(0.05, 0.15, 1),
						0.25, Pwhite(0.05, 0.15, 2),
						0.25, Pwhite(0.05, 0.15, 2),
						0.25, Pwhite(0.05, 0.15, 3),
					], 1), // amp

					Pseq([ 0, -1, 1], 15), // Pan2

					Pshuf( (100!15), 1)

					],1),

			], 1)



			], inf)

).play(t);

Pbindef(\clickSin, \amp, 0.05).play(t);
})
)


145

60/130

(145 * 2.1666666666667).round // beats



45
+
32
+
45
+
64
+
45
+
32
+
45


308 * 0.46153846153846

1/1.66


314 * 0.60240963855422
