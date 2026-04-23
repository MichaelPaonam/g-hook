setcps(138/120/2)

stack(
  // Kick: 4-on-floor
  s("bd").struct("x ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ ~").bank("RolandTR909").gain(1.0),

  // Snare: on 2 & 4
  s("sd").struct("~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~").bank("RolandTR909").gain(0.75),

  // Closed hi-hat: 8th notes with groove
  s("hh*8").bank("RolandTR909").gain(0.35),

  // Open hat: off-beat punctuation
  s("oh").struct("~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~").bank("RolandTR909").gain(0.3),

  // Acid bass: TB-303 style sawtooth
  note("c2 ~ c2 ~ eb2 ~ c2 ~ bb1 ~ c2 ~ f2 ~ c2 ~")
    .s("sawtooth")
    .cutoff("<400 600 800 1200 800 600>")
    .resonance(18)
    .gain(0.75)
    .decay(0.2)
    .sustain(0.1),

  // Hypnotic pad: slow chord swells
  note("<[c3,eb3,g3,bb3] [bb2,d3,f3,ab3] [ab2,c3,eb3,g3] [g2,bb2,d3,f3]>")
    .s("sawtooth")
    .cutoff(300)
    .resonance(4)
    .gain(0.25)
    .attack(1.5)
    .decay(2)
    .sustain(0.6)
    .slow(4),

  // Trance arp: rapid 16th note ascending figures
  note("c4 eb4 g4 bb4 c5 bb4 g4 eb4 bb3 d4 f4 ab4 bb4 ab4 f4 d4")
    .s("square")
    .cutoff(1800)
    .resonance(6)
    .gain(0.4)
    .attack(0.005)
    .decay(0.1)
    .sustain(0.3)
    .delay(0.15)
    .delaytime(0.125)
    .delayfeedback(0.4),

  // Lead melody: soaring synth phrase entering every other 4 cycles
  note("c5 ~ eb5 ~ g5 ~ bb5 g5 f5 ~ eb5 ~ d5 ~ c5 ~")
    .s("sawtooth")
    .cutoff(2200)
    .resonance(8)
    .gain(0.55)
    .attack(0.02)
    .decay(0.3)
    .sustain(0.5)
    .slow(2)
    .delay(0.2)
    .delaytime(0.25)
    .delayfeedback(0.45),

  // Sub bass: deep sine underpinning
  note("<c1 bb0 ab0 g0>")
    .s("sine")
    .gain(0.6)
    .slow(4)
    .decay(0.8)
    .sustain(0.5),

  // Riser: filter-swept noise swell every 8 cycles
  s("whitenoise")
    .cutoff("<200 400 800 1600 3200 6400 3200 1600>/8")
    .gain(0.15)
    .slow(8)
)
