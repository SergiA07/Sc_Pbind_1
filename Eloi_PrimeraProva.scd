//MASTER
s.boot
(
ServerQuit.removeAll;
ServerBoot.removeAll;
ServerTree.removeAll;
Buffer.freeAll;

s.waitForBoot({

	~bus = Dictionary.new;
	~bus.add(\reverb0 -> Bus.audio(s,2));
	~bus.add(\reverb1 -> Bus.audio(s,2));
	~bus.add(\pitchShift -> Bus.audio(s,2));
	~bus.add(\delay -> Bus.audio(s,2));
	~bus.add(\distorsion -> Bus.audio(s,2));

	s.sync;

	SynthDef(\delay, {
		arg maxtime=0.2, time=0.1, decay= 2, in=40, out=0;
		var senal;
		senal =In.ar(in, 2);
		senal= AllpassN.ar(senal, maxtime, time.clip(0, maxtime), decay);
		Out.ar(out, senal)}).add;

	s.sync;

	~adreces = (PathName(thisProcess.nowExecutingPath).parentPath ++ "sons/*").pathMatch;
	~exclusio = PathName(thisProcess.nowExecutingPath).parentPath ++ "sons/Icon";
	~adreces.do({ arg adreca, indice; adreca.compare(~exclusio).postln; if(adreca.compare(~exclusio).abs <= 1) {~adreces.removeAt(indice)}});
	~buffers = ~adreces.collect({arg adreca; Buffer.readChannel(s,adreca, channels:[0])});

	s.sync;

	~processing = NetAddr("127.0.0.1", 12000);
	~tempo = TempoClock.new(130/60).permanent_(true);

	s.sync;

	SynthDef(\play, {
		arg buf=0, vel=1, pos=0, cutFreqLow = 20000, cutFreqHigh = 0, atk=0.001, sus=0.2, rel=0.05, amp=1, pan=0, out=0;
		var senal, env;
	    env = Env([0,1,1,0],[atk,sus,rel],[1,0,-1]).kr(2);
		senal = PlayBuf.ar(1, buf, vel * BufRateScale.kr(buf), startPos:pos, loop: 0);
		senal = senal * env;
		senal = LPF.ar(senal, cutFreqLow);
		senal = HPF.ar(senal, cutFreqHigh);
		senal = Pan2.ar(senal, pan, amp);
		OffsetOut.ar(out, senal);}).add;


	SynthDef(\kick2, {
		arg amp=1, ampCua=0.5, rqCua=0.05, pan=0, out=0, rel=1, freqPulse=2,
		 freqGreu=57, freqMitja=750, freqAguda=1320, freqGreuArribada=52,
		 volFreqAguda=0.5, volFreqMitja=1, volFreqGreu=1;
	    var snd, cua, final;
	    snd = DC.ar(0);
	    snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), freqAguda) * Env.perc(0.003, 0.03).kr * volFreqAguda);
	    snd = snd + (SinOsc.ar(XLine.ar(freqMitja, 161, 0.02)) * Env.perc(0.0005, 0.02).kr * volFreqMitja);
	    snd = snd + (SinOsc.ar(XLine.ar(freqGreu, freqGreuArribada, 0.04)) * Env.perc(0.0005, 0.3).kr * volFreqGreu);
	    snd = snd.tanh;

		cua = ClipNoise.ar(1);
		cua = BPF.ar(cua, freqAguda, Env([0.25, rqCua], [rel], \lin).kr);
		cua = cua * LFPulse.kr(Env([0, freqPulse, 0], [rel/2, rel/2], \lin).kr);
		cua = cua * Env([0.01, ampCua, 0.001], [0.005, rel], \sine).kr(2);

		final = snd + cua;
		final = Pan2.ar(final, pan, amp);

		Out.ar(out, final);}).add;


	SynthDef(\kickGuapo, {
      	arg basefreq = 50, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 0.5, /*Originalment va amb amp=1*/decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out = 0;
      	var fcurve, env, sig; //usa l'env (de 350 a 50 en 0.005) com a freq pel SinOsc. Crec que és el component tonal de baix.
		fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp));
	  	env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2);  //Aquesta sí és l'envolvent temporal i percussiva?
      	sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
      	Out.ar(out, sig ! 2)}).add;


	SynthDef(\noise1, {
		arg amp, rel=0.1, pan, filtre=1000;
		var sig, env;
		sig = WhiteNoise.ar(amp);
		env = Env.perc(0.01, rel).kr(2);
		sig = HPF.ar(sig, filtre);
		sig = sig * env;
		sig = Pan2.ar(sig, pan);
		Out.ar(0, sig);}).add;


	SynthDef(\crackle1, {
		arg amp, chaos=1.5, pan, filtre=1000;
		var sig, env;
		sig = Crackle.ar(chaos, amp);
		sig = HPF.ar(sig, filtre);
		Out.ar(0, sig);}).add;


	SynthDef(\click1, {
		arg freq=100, amp=1;
		var sig, env;
		env = Env.perc(0.01, 0.25).kr(2);
		sig = SinOsc.ar(freq,0, amp);
		sig = sig * env;
		Out.ar(0, sig);}).add;



	Pbindef.all.do(_.clear);

	s.sync;







	///// DELCARACIO DE PBIND's DEFINITUS

	Pbindef(\noise4_5,
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
			], inf));

	Pbindef(\bomboProcessing,
		\instrument, \kick2,
		\dur, Prand([1, 0.25, 0.5], inf) / 2,
		\pfunc, Ptime.new,
		\amp, Pwhite(0.25, 1, inf),
		\pan, Pwhite(-0.75, 0.75, inf),
		\prova, Pfunc({
			arg event;
			var ampCercle, posCercle;
			ampCercle = event[\amp].linlin(0.25, 1, 25, 150).asInteger;
			posCercle = event[\pan].linlin(-0.75, 0.75, 100, 500).asInteger;
			~processing.sendMsg("/", posCercle, 180, ampCercle, ampCercle);
			}));

	Pbindef(\samples2,
		\instrument, \play,
		\buf, ~buffers[1],
		\vel, Prand([ 1.5], inf),
	    \amp, Pexprand(0.5, 0.95, inf),
		\dur, Pwrand([Pseq([1/8],8), Pseq([1/4],4), Pseq([1/2],2)],[0.95,0.03,0.02],inf),
		\dur, Prand([1/4, 1/2], inf),
		//\pos, Pwhite(0, Pkey(\buf).collect(_.numFrames), inf).trace,
		\pos, 530564,
		\sus, Pkey(\dur) * 0.125 * Pkey(\vel).sqrt.reciprocal,
		\pan, Pwhite(-1, 1, inf),
		//\out, Pwrand( [0, ~bus[\reverb0], ~bus[\reverb1], ~bus[\pitchShift]],[0.8, 0.05, 0.05, 0.1],inf),
		\out, 0
		);




	///// EXECUCIÓ DE PBIND

	(
	Routine({
		////EVENT1 - 5 vegades 4/4 + 5/4
		s.bind({
			Pbindef(\noise4_5).play(t);
			});

		18.wait;

		//(1 * 4).wait; // 1 compàs de 4/4

		////EVENT2
		s.bind({
			Pbindef(\noise4_5).stop;
			Pbindef(\bomboProcessing).play(t);
			Pbindef(\samples2).play(t);
			});

		(3 * 5).wait;

		s.bind({
			Pbindef(\bomboProcessing).stop;
			Pbindef(\samples2).stop;
			});


		  // 3 compasos de 5/4
		}).play(t);
	);


	});
)




/// ESTRUCTURA PEÇA


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


















































///////////////////////////// PBIND's PROVES


Pbindef(\granocaotico1,
    \instrument, \play,
	\buf, Pfunc({  ~sampleEscogido = (0 .. (~buffers.size -1)).choose; ~samplesFinal = ~buffers.at(~sampleEscogido); }),
	\vel, Pwhite(0.1, 2.5, inf),
    \amp, Pexprand(0.5, 0.95, inf) * Pseg([0.75, 0.75, 0.25, 0.5, 1 ], [ 3*4, 4, 4, 4 ]),
	\dur, Pwrand([Pseq([1/8],8), Pseq([1/4],4), Pseq([1/2],2)],[0.95,0.03,0.02],inf) / 8,
	\pos, Pwhite(0, Pkey(\buf).collect(_.numFrames), inf),
	\sus, Pkey(\dur) *  1.1 *  Pkey(\vel).sqrt.reciprocal,
	\pan, Pwrand([Pseq([0],16),Pseq([-1,1],1),Pwhite(-0.8,0.8,8)],[0.8,0.1,0.1],inf),
	//\out, Pwrand( [0, ~bus[\reverb0], ~bus[\reverb1], ~bus[\pitchShift]],[0.8, 0.05, 0.05, 0.1],inf),
	\out, 0).play(t);
//.quant_([1]);

Pbindef(\samples1,
    \instrument, \play,
	\buf, ~buffers[2],
	\vel, Prand([ 1.5], inf),
    \amp, Pexprand(0.5, 0.95, inf),
	\dur, Pwrand([Pseq([1/8],8), Pseq([1/4],4), Pseq([1/2],2)],[0.95,0.03,0.02],inf),
	\dur, Prand([1/4, 1/2], inf),
	\pos, Pwhite(0, Pkey(\buf).collect(_.numFrames), inf).trace,
	\pos, 330564,
	\sus, Pkey(\dur) *  0.125 *  Pkey(\vel).sqrt.reciprocal,
	\pan, Pwhite(-1, 1, inf),
	//\out, Pwrand( [0, ~bus[\reverb0], ~bus[\reverb1], ~bus[\pitchShift]],[0.8, 0.05, 0.05, 0.1],inf),
	\out, 20).play(t);



Pbindef(\bomboprova,
	\instrument, \kick2,
	\dur, Prand([4], inf),

	\freqGreu, Pwhite(50, 75, inf).round,
	\freqGreuArribada, Pkey(\freqGreu) - Pwhite(10, 20, inf),
	\volFreqAguda, 0.1,
	\pan, 0,
	\amp, 0.75,

	\rel, Pkey(\dur) * 1,
	\freqPulse, Pkey(\dur) * Prand([ 4], inf),
	\ampCua, 0.25,
	\rqCua, 0.001).play(t)





(
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



			\amp, Pn( Plazy({ Pshuf( (0.5!4) ++ (0.35!9), 2) }), inf)).play(t);

Pbindef(\noise,
	\instrument, \noise1,
	\dur, Prand([1/4,1/2], inf),
	\rel, Pn( Plazy({ Pshuf( [0.05, 0.05, 0.1, 0.1, 0.25] /4, 2) }), inf),
	\amp, 0.25,
	\pan, Pwhite(-1, 1, inf),
	\filtre,  Pseq([
		Pseq( (100!30), 1),
		Pexprand(100, 8000, 20)
	], inf)).play(t);

Pbindef(\clickSin,
	\instrument, \click1,
	\dur, 1,
	\freq, Pseq([800, 500, 500, 500, 800, 500, 500, 500, 500] , inf),
	\amp, Pseq( Array.geom(5, 0.1, 0.9), inf)).play(t);

Pmono(\crackle1,
	\dur, 1/8,
	\chaos, Pwhite(1.5, 1.95, inf),
	\filtre, Pwhite(5000, 12000, inf),
	\amp, Pkey(\filtre).linlin(5000, 12000, 0.01, 0.95) /4).play(t);

Pbindef(\clickSin, \amp, 0.05).play(t);

})
)
