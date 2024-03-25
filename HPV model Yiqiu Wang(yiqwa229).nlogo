;; Yiqiu Wang(yiqwa229)

turtles-own[
age
gender
active-adult?      ; 18-45 years old, unmarried, healthy adult
married?
date-id            ; id of current interacting mate(unmarried)
spouse             ; id of spouse if married
infected?
infected-time-one-for-six-month
vaccinated?
risk               ; probability of being infected with hpv
number-of-child
; a married couple could have no more than 2 children
;(if unmaried and has child, the child is not counted here and the number of such children has no limitation)
not-in-good-health ; patients' health conditions become so bad that they could no longer perform sexual behaviors
wait-for-treatment
; agents are diagnosed duing annual check or they seek help after they stop feeling well
;(they can recover in 2 years after they are diagnosed/seek help)
infected-once?     ; whether the agent has been diagnosed once through regular-check or not-in-good-health
contacts           ; friends of the agent
ma-id              ; parents' id for newborn agents
pa-id
]

to setup
  ca
  reset-ticks

  ; set the environment(agents cannot cross the black borders)
  ask patches [
    set pcolor white
    if abs pxcor = floor (world-width / 2) [set pcolor black]
    if abs pycor = floor (world-height / 2) [set pcolor black]
  ]

  let maxturtles count patches with [pcolor = white]         ; create agents based on "density"
  ask n-of (maxturtles * density / 100) patches with [pcolor = white] [sprout 1]

  ask turtles[        ; ordinary people
  set shape "person"
  set color grey + 2

  set age round random-skewed-age   ; set age based on a skewed distribution

  set gender ifelse-value (random-float 1 < 0.45) [ 1 ] [ 2 ]
  ; set gender almost 50/50 chance of male/female(with female being more likely)

  set married? false     ; no agent is married in the beginning

  set date-id 99999

  set spouse 99999

  set infected-time-one-for-six-month 0    ; all agents have not yet been infected

  set vaccinated? false  ; set all vaccinated status false(will select a number of agents to be vaccinated in later steps)

  ifelse (age >= 18 and age <= 45) [set active-adult? true][set active-adult? false set shape "circle"]
  ; set active-adult? status(no one is married or in bad health when we set up so we just specify the age)

  set infected? false  ; set all infection status false(will select a number of agents to be infected in later steps)

  set risk 100        ; set infection rate 100 in the beginning

  set number-of-child 0   ; no child in the beginnning

  set not-in-good-health false  ; all in good health

  set wait-for-treatment 0 ; not waiting for treatment

  set infected-once? false  ; no one has been diagnosed

  create-links-with (other turtles-on neighbors)
  set contacts [who] of link-neighbors  ; find agents on neighbor patches and set them as my contacts
  ask links [set hidden? true]

  set ma-id 99999

  set pa-id 99999
  ]

  ; Create the seed of the virus based on initial-patient-rate
  let allturtles count turtles
  ask n-of (allturtles * initial-patient-rate / 100) turtles[
    set color red
    set infected? true
  ]

  ; vaccine
  ; set a certain number of agents to be vaccinated based on initial-vaccine-rate
  ask n-of (allturtles * initial-vaccine-rate / 100) turtles[
  set vaccinated? true
      ]

  ask turtles with [vaccinated? = true and infected? = false][set risk 30]    ; change the risk of vaccinated agents
  ask turtles with [vaccinated? = true and infected? = true][set risk 50]     ; vaccine is less effective for infected agents

end

to go
  if(ticks = 100)[stop]   ;;; when to stop: 2 ticks a year . a total of 50 years so 100 ticks
  tick
  ; agents in different age groups have different probability of dying in each tick(the older a agent is, the more likely it dies)
  ; when they die, their links with others also die and their spouse become single(not married) again
  ask turtles with [age >= 60 and age < 70] [
    if random-float 1 < 0.5 [
      ask my-links[die]
      if married? = true and turtle spouse != nobody[
          ask turtle spouse[
            set married? false
            set spouse 99999
            set number-of-child 0
        ]
      ]
      die]
  ]

    ask turtles with [age >= 70] [
    if random-float 1 < 0.8 [
      ask my-links[die]
      if married? = true and turtle spouse != nobody[
          ask turtle spouse[
            set married? false
            set spouse 99999
            set number-of-child 0
        ]
      ]
      die]
  ]

    ask turtles with [age = 80] [
      ask my-links[die]
      if married? = true and turtle spouse != nobody[
          ask turtle spouse[
            set married? false
            set spouse 99999
            set number-of-child 0
        ]
      ]
      die]

  ; die of disease
  ask turtles with [not-in-good-health = true][
    if random-float 1 < 0.1[
      ask my-links[die]
      if married? = true and turtle spouse != nobody[
          ask turtle spouse[
            set married? false
            set spouse 99999
            set number-of-child 0
        ]
      ]
      die]
  ]

  ; update infected time
  ask turtles with [infected? = true][set infected-time-one-for-six-month (infected-time-one-for-six-month + 1)]

  ; after a certain amount of time, the turtle should be in bad health and is no longer an active adult
  ask turtles with [infected-time-one-for-six-month != 0 and infected-time-one-for-six-month mod 2 = 0][
    ; every year after infection the infected agent might feel its health condition deteriorating
     if random-float 1 < 0.05
     [set not-in-good-health true]
  ]
  ; agents suffer from bad health would start to seek help(but help takes time)
  ask turtles with [not-in-good-health = true] [
     set wait-for-treatment wait-for-treatment + 1
  ]

  ; after two years, patients can recover
  ask turtles with [wait-for-treatment = 4][
    recover
    if married? = true and turtle spouse != nobody
    [let partner-condition [infected?] of turtle spouse
     if partner-condition = true [set infected? true set color red]
    ]
  ]

  ask turtles [set contacts [who] of link-neighbors] ; update contacts: remove dead turtles

  ; only when the agent is 18-45 years old, not married and "looks healthy" can it be an active-adult
  ask turtles [ifelse (age >= 18 and age <= 45 and married? = false and not-in-good-health = false)
    [set active-adult? true set shape "person"][set active-adult? false set shape "circle"]]

  ; married couples can have children(no more than 2) while they stay married
  ask turtles with [married? = true and age >= 18 and age <= 45 and not-in-good-health = false and gender = 2 and number-of-child < 2][
    ;print (word "Person " who " gave birth while married")
    give-birth-within-marriage ]


  ;;;;;;;
  ; only active-adults can "date"
  ask turtles with [active-adult? = true]
  [ random-walk
    date]

  ;;; divorce
   divorce

  ; after a year, every agent age up
  if(ticks != 0 and (ticks mod 2) = 0)[
    ask turtles [set age (age + 1)]
  ]

  ; health-check
  health-check-every-two-years

  ask turtles [set date-id 99999] ; reset id of current date
end

to random-walk
  let newspots neighbors with [pcolor = white]  ; move randomly to nearby white patches
  move-to one-of newspots
end

to date
  let my-id who

  let potential-mate (turtles-on neighbors) with [active-adult? = true and married? = false and gender != [gender] of myself]
  if any? potential-mate [
  let my-date one-of potential-mate      ; find potential date(active, not married and has a differnt gender)

    set date-id [who] of my-date
    let my-date-id [who] of my-date
    ask my-date [set date-id my-id]    ; update date-id

  let my-risk risk
  let mate-risk [risk] of my-date
  let my-disease infected?
  let mate-disease [infected?] of my-date

  if random-float 100 < interactive-rate[   ; choose to interact(date) or not
       let con random 100
       ifelse con < condom-using-rate  ; if choose to interact, choose to use a condom or not
       [set my-risk (my-risk * 0.3)          ;;; how can condom protect agents?
        set mate-risk (mate-risk * 0.3)      ; if using condom, update risks of both agents

        if (my-disease = true and mate-disease = false) [   ; can I infect my date?
        if random 100 < mate-risk
        [ask my-date
            [set infected? true
             set color red
          ]
          ]
          ]
        if (my-disease = false and mate-disease = true) [   ; can my date infect me?
        if random 100 < my-risk
        [set infected? true
         set color red]
          ]
       ]
    ;;;;;;
       [  ; if not using a condom
      if (my-disease = true and mate-disease = false) [
        if random-float 100 < mate-risk
        [ask my-date
            [set infected? true
             set color red
          ]]
          ]
      if (my-disease = false and mate-disease = true) [
        if random-float 100 < my-risk
        [set infected? true
          set color red]
      ]

     ; without condom could probably create a newborn(but this newborn will not be count in number-of-child)
        let baby random-float 1
        if baby < 0.5 [hatch 1 [
                              set shape "circle"
                              set color grey + 2
                          set age 0
                          set gender ifelse-value (random-float 1 < 0.45) [ 1 ] [ 2 ]
                          set active-adult? false
                          set married? false
                          set ma-id my-date-id   ; it does not matter so much if ma-id refers to an agent with gender equals to 1(male)
                          set pa-id my-id     ; we just want to record the id of the parents
                          set date-id 99999
                          set spouse 99999
                          set infected-time-one-for-six-month 0

                          choose-vaccine

          ;;;;; check if parent is infected and set infected? status (and risk)
                          ifelse (my-disease = true or mate-disease = true);;; need to check both side of parents done
                                  [set infected? true
                                  set color red]
                                  [set infected? false]
                          if infected? = true and vaccinated? = true
                          [set risk 50
                           ;print(word "Vaccine did not work well on BABY " who " because of infection on tick " ticks)
                          ]

                          set number-of-child 0
                          set not-in-good-health false
                          set wait-for-treatment 0
                          set infected-once? false

                          create-links-with (other turtles-on neighbors)
                          ask links [set hidden? true]

                          set contacts [who] of link-neighbors

                          ;print(word "BABY " who " was born by" ma-id " and " pa-id "on tick " ticks);;;;;
                            ]
                      ]
        ]
  ; marriage(agents after choosing to interact can get married)
      if random-float 100 < marriage-rate [marry]
  ]
 ]

end

to marry
    let my-date turtle date-id
    let my-disease-update infected?
    let mate-disease-update [infected?] of my-date

      set married? true    ; set married status and id of spouse
      set spouse date-id

      let my-id who
      ask my-date [
        set married? true
        set spouse my-id
      ]
      ; we assume as long as one agent in the married couple is infected, the spouse must be infected
      if (my-disease-update = true and mate-disease-update = false)[ask my-date [set infected? true set color red]]
      if (my-disease-update = false and mate-disease-update = true)[set infected? true set color red]
      ;print(word "Person " who " and person" [who] of my-date " married on tick " ticks);;;;;;
end

to give-birth-within-marriage
    let my-id who
    let partner-id spouse

    if turtle partner-id != nobody[

    ask turtle partner-id [set number-of-child (number-of-child + 1)]
    set number-of-child (number-of-child + 1)  ; update number of children the couple has

    hatch 1[
    ;print(word "BABY " who "was born by its married parents on tick " ticks)
      set shape "circle"
      set color grey + 2
    set ma-id my-id               ; record parents' id
    set pa-id partner-id

    set age 0
    set gender ifelse-value (random-float 1 < 0.45) [ 1 ] [ 2 ]
    set active-adult? false
    set married? false
    set spouse 99999
    set date-id 99999
    set infected-time-one-for-six-month 0

    choose-vaccine   ; set vaccinated? status based on the vaccine-strategy-for-newborn in the interface

    ;set infected? status based on one's parents
      ifelse ([infected?] of turtle ma-id = true or [infected?] of turtle pa-id = true)
      ; as long as one of the parents is infected, the child is infected
      [set infected? true  set color red][set infected? false]

    if infected? = true and vaccinated? = true
      [set risk 50
       ;print(word "Vaccine did not work well on BABY " who " because of infection on tick " ticks)
      ]

    set number-of-child 0

    set not-in-good-health false
    set wait-for-treatment 0
    set infected-once? false

    create-links-with (other turtles-on neighbors)    ; create links with others
    ask links [set hidden? true]
    set contacts [who] of link-neighbors

    ]
  ]
end

to divorce     ; reset marriage status, number of children and spouse id
  ask turtles with [married? = true]
  [if random-float 100 < divorce-rate [
       if turtle spouse != nobody[
       ;print(word "Person " who " and person" spouse " divorced on tick " ticks)
          ask turtle spouse [
          set married? false
          set number-of-child 0
          set spouse 99999]

          set married? false
          set number-of-child 0
          set spouse 99999
       ]
    ]
  ]
end

to health-check-every-two-years     ; every 2 year some agents(based on regular-check-cover-rate) would be chosen to undergo a health check
  if ticks != 0 and ticks mod 4 = 0 [
  let population count turtles
  let checked n-of (population * regular-check-cover-rate / 100) turtles
  ask checked with [infected? = true and not-in-good-health = false][   ; for those who are infected but still appear to be health
    set not-in-good-health true      ; diagnosed and will have treatment
     ]
  ]
end

to recover    ; not infected or in bad health status anymore
  set infected? false
  set not-in-good-health false
  set infected-time-one-for-six-month 0
  set wait-for-treatment 0
  set infected-once? true   ; infection history
  set color grey + 2
end


to choose-vaccine
  if(vaccine-strategy-of-newborn = "anti-vaccine")[anti-vac]
  if(vaccine-strategy-of-newborn = "society")[soc]
  if(vaccine-strategy-of-newborn = "one-of-my-parents")[one-of-my-par]
  if(vaccine-strategy-of-newborn = "both-of-my-parents")[both-of-my-par]
  if(vaccine-strategy-of-newborn = "lesson-from-family-friend")[lesson-from-ff]
  if(vaccine-strategy-of-newborn = "mandatory")[mand]
end

to anti-vac
  set vaccinated? false    ; reject vaccine(no protection)
  set risk 100
  ;print(word "BABY " who "did not get vaccine because of anti-vaccine on tick " ticks)
end

to soc
    ifelse random 100 < initial-vaccine-rate [set vaccinated? true][set vaccinated? false]
    ; get vaccinated based on initial-vaccine-rate(follow the crowd)
    ifelse vaccinated? = true
  [set risk 30
    ;print(word "BABY " who "got society vaccine on tick " ticks)
  ]
  [set risk 100
    ;print(word "BABY " who "didn't get society vaccine on tick " ticks)
  ]
end

to one-of-my-par   ; as long as one of the parents is vaccinated, the child is vaccinated
  let mom turtle ma-id
  let dad turtle pa-id
  ifelse ([vaccinated?] of mom = true or [vaccinated?] of dad = true)
  [set vaccinated? true
  set risk 30
  ;print(word "BABY " who "got vaccine because at least one of the parents allowed it on tick " ticks)
  ]
  [set vaccinated? false
  set risk 100
  ;print(word "BABY " who "did not vaccine because neither of parents allowed it on tick " ticks)
  ]
end

to both-of-my-par  ; only when both parents are vaccinated, the children is vaccinated
  let mom turtle ma-id
  let dad turtle pa-id
  ifelse ([vaccinated?] of mom = true and [vaccinated?] of dad = true)
  [set vaccinated? true
  set risk 30
  ;print(word "BABY " who "got vaccine because both of the parents allowed it on tick " ticks)
  ]
  [set vaccinated? false
  set risk 100
  ;print(word "BABY " who "did not get vaccine because at least one of the parents refused it on tick " ticks)
  ]
end

to lesson-from-ff
  ; as long as one of the parents is vaccinated, the child is vaccinated
  ; but if neither of the parents is vaccinated, they can seek advice from a family friend(contacts of parents) if there is any
  ; if the friend is not in good health or infected once or vaccinated
  ; the child should be vaccinated
  let mom turtle ma-id
  let dad turtle pa-id
  ifelse ([vaccinated?] of mom = true or [vaccinated?] of dad = true)
  [set vaccinated? true
   set risk 30
   ;print(word "BABY " who "got vaccine because of parents before asking a family friend on tick " ticks)
  ]
  [ let family-friends sentence [contacts] of mom [contacts] of dad
      ifelse length family-friends != 0[
      let this-friend turtle (one-of family-friends)
      ifelse ([not-in-good-health] of this-friend = true or [infected-once?] of this-friend = true or [vaccinated?] of this-friend = true)
      [set vaccinated? true set risk 30
       ;print(word "BABY " who "got vaccine because of parents or a family friend on tick " ticks)
      ][set vaccinated? false set risk 100
       ;print(word "BABY " who "did not get vaccine because of parents or a family friend on tick " ticks)
      ]
    ][set vaccinated? false
      set risk 100
       ;print(word "BABY " who "failed to get vaccine because there is no family friend to ask on tick " ticks)
    ]
  ]
end

to mand ;mandatory
  set vaccinated? true
  set risk 30
  ;print(word "BABY " who "got vaccine because it is mandatory on tick " ticks)
end


to-report random-skewed-age
  let agemean 25   ; Mean value
  let sd 7      ; Standard deviation

  let value random-normal agemean sd  ; first use a normal distribution
  let skewness value - agemean
  let skewness_factor 3  ; Adjust the skewness level by changing the factor(it is positive so most people should be younger than the original agemean)

  let skewed_value value + (skewness * skewness_factor)  ; get the skewed value

  let min_value 14
  let max_value 50     ; in the beginning, the youngest agents should be 14 years old and the eldest 50

  let my_value skewed_value        ; do not let the age exceed the min and max age

  if skewed_value < min_value [
    set my_value min_value
  ]

  if skewed_value > max_value [
    set my_value max_value
  ]

  report my_value
end

to-report infection-rate
  let infected count turtles with [infected? = true]
  let pop count turtles
  report precision (infected / pop * 100) 2
end

to-report vaccinated-rate
  let vac count turtles with [vaccinated? = true]
  let pop count turtles
  report precision (vac / pop * 100) 2
end

to-report protected-people
 report count turtles with [vaccinated? = true]
end

to-report not-protected-people
 report count turtles with [vaccinated? = false]
end
@#$#@#$#@
GRAPHICS-WINDOW
227
10
560
344
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-12
12
-12
12
0
0
1
ticks
30.0

SLIDER
587
58
760
91
density
density
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
8
27
181
60
initial-patient-rate
initial-patient-rate
0
50
20.0
1
1
%
HORIZONTAL

BUTTON
586
10
654
44
set up
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
155
186
188
condom-using-rate
condom-using-rate
0
100
30.0
1
1
%
HORIZONTAL

SLIDER
12
200
185
233
initial-vaccine-rate
initial-vaccine-rate
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
10
246
216
279
regular-check-cover-rate
regular-check-cover-rate
0
100
30.0
1
1
%
HORIZONTAL

SLIDER
11
294
183
327
interactive-rate
interactive-rate
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
11
340
183
373
marriage-rate
marriage-rate
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
11
388
183
421
divorce-rate
divorce-rate
0
100
35.0
1
1
%
HORIZONTAL

BUTTON
587
103
650
136
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
9
87
221
132
vaccine-strategy-of-newborn
vaccine-strategy-of-newborn
"anti-vaccine" "society" "one-of-my-parents" "both-of-my-parents" "lesson-from-family-friend" "mandatory"
1

BUTTON
669
103
732
136
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
581
147
781
297
infection-rate
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ifelse ticks = 0 [plot initial-patient-rate][plot infection-rate]"

PLOT
580
309
780
459
vaccinated-rate
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ifelse ticks = 0 [plot initial-vaccine-rate][plot vaccinated-rate]"

MONITOR
250
355
347
400
NIL
protected-people
17
1
11

MONITOR
250
401
366
446
NIL
not-protected-people
17
1
11

@#$#@#$#@
## 1.     PURPOSE AND PATTERNS
This model is inspired by the research on AIDS done by Wang and colleagues(2011) using Repast Simphony1.2. In their model, they introduced sex, age, maximum age, partner, health status, condom using rate, infected time, being diagnosed or not, married status, as well as the number of people a patient could infect. 

In this model about the spread and prevention of HPV, HPV vaccine is introduced. There are also different vaccine injection  strategies for newborns. Infected agents who are not in good health could die of disease and all agents could die of age. The health condition of infected agents could deteriorate and then they would seek help. Regular health check provided by the government is also introduced but it has a cover rate so if infected agents who are still in good health is chosen to take one health check, they are immediately recognized as not in good health and start treatment. Social network is included in the model so most agents have a certain number of contacts. If "vaccine-strategy-of-newborn" is set to "lesson-from-family-friend", the newborn will be vaccinated as long as there is one of its parent vaccinated. Otherwise, it checks one of its parents' contacts, if that person is vaccinated or not in good health or has been infected once, the baby will be vacccinated. Otherwise, the newborn will not be vaccinated. 

This model simulates the spread of HPV(human papillomavirus) in a population given different settings.

According to World Health Organization(2022), An HPV infection is caused by the human papillomavirus. While many infections do not lead to severe consequences on health, an infection could result in warts or precancerous lesions. These lesions increase the risk of cancer of the cervix, vulva, vagina, penis and other body parts based on where the lesions happen. HPV is the main cause of cervical cancer.

"condom-using-rate", "initial-vaccine-rate", "regular-check-cover-rate", "interactive-rate", "marriage-rate", "divorce-rate" and "vaccine-strategy-of-newborn" is set before the model start to run.

The model is designed to test how different vaccine strategy for newborn as well as different "condom-using-rate" and other variables could influence the infection rate and the vaccinated rate of a population in 50 years to find effective measures that could be taken to contain the spread of HPV. It has been proved that people who regularly use condoms during sexual contacts is 70% less likely to be infected than those who seldom use condoms(Winer et al. 2006). The effectiveness of HPV vaccine is around 70% if the injection is done in a relatively young age(first dose before age 20)(Leval et al. 2013). Although HPV is most commonly known for transmition through sexual contacts, baby whose mother has vaginal/vulvar condyloma is over 200 times more likely to be infected with HPV through vertical transmission than those has healthy mothers(Burlamaqui et al. 2017). Apart from these modes of transmission,
transmission between the hands and genitals(Hernandez et al. 2008), through shared objects(Tsai et al. 1993) have also been proven. So in this model, we assume people who perform sexual behaviours have different risk levels based on whether or not they are vaccinated and use condoms. We also assume that married couples always infect each other and parents always infect children considering not only do married couples perform sexual behaviours without condoms sometimes which increases their risk of being infected, and mothers infect babies while giving birth, but also interact quite often and probably share items as a family.

Online interaction and the spread of misinformation especially during the COVID-19 pandemic as well as anti-vaccine movements have become an obstacle of promoting HPV vaccine as it increased parents’ concern about HPV vaccines(Boucher et al. 2023; National Cancer Institute 2021; Argyris et al. 2021). Reports on Japanese media about vaccine-related adverse events has lowered the willingness of vaccination and even resulted in the government suspending the recommendation of the vaccine(Machida and Inoue 2023).

To observe pattern of HPV spread and vaccine injection in 50 years, two plots are created based on the number of infected people over the whole population(infection-rate) and the number of vaccinated people over the whole population(vaccinated-rate).


## 2.   ENTITIES, STATE VARIABLES AND SCALES
The environment consists of 12*12 patches. All global variables such as density, vaccine-strategy-of-newborn and the seven rates could be changed before setting up the model and are constant through out the simulation. One tick in the model stands for six months in reality and the model will stop when ticks reach 100, which is 50  years after start of the simulation.

 
There is only one kind of agents in the model. The following are their attributes:

a. 	age: a random number ranging from 0 to 80. When the model is set up, differnt age values are assigned to every agent based on a positive skewed distribution
agemean= 25    sd=7    skewness_factor=3

(random-normal agemean sd) + ((random-normal agemean sd) - agemean) * skewness_factor

Note: When the model initializes, the minimum age is 14 and the maximum age is 50. So age value lower than 14 is set 14 and age value higher than 50 is set 50.


b. 	gender: This attribute record a value equals to 1 or 2 with 2 standing for female. The probability of being a male is 45% and female 55%. This probabilty also holds for newborn.

c. 	active-adult?: (true/false) Only when an agent is 18-45 years old, unmarried and in good health can it record "true" in this attribute. This attribute is updated in every tick.

d. 	married?:(true/false)marriage status

e. 	date-id: This attribute is set as 99999 (to avoid confusion with 0) when an agent is created(born). When active-adults decide to date, they update the value to the id of their dates. This attribute is reset to 99999 in each tick.

f.      spouse: This attribute is set as 99999 (to avoid confusion with 0) when an agent is created(born). After dating, if an agent decides to marry its date, it and its date set value based on date-ids they just updated. If an agent decides to divorce, it and its spouse both reset this value to 99999. 

g.      infected?: whether or not the agent is infected with HPV

h.      infected-time-one-for-six-month: 0 when the agent is not infected. 1 stands for six months. After an agent is infected, this value adds 1 in every tick. After one year of being infected(when this attribute = 2), the agent has a probability of 10% of having bad health every year(when this attribute = 2/4/6...). After an infected agent recovers, this attribute is reset to 0. 

i.      vaccinated?: whether or not this agent has been vaccinated

j.      risk: (30/50/100) For a not infected agent, this attribute is 100(not protected) if it has not been vaccinated and 30(highly protected) if it has been vaccinated. For an infected agent, the attribute is still 100 if it has not been vaccinated but 50(not-so-protected) if it has been vaccinated because we assume that the vaccine does not work on it as effectively as on not infected agents. The highest risk is set to be 100 instead of 40, which is suggested as the risk of being infected per sexual behaviour(Burchell et al. 2006) because each tick stands for six months, and when agents are dating we expect that during a six-month relationship the two agents would have other physical contacts besides sexual contacts so the risk is accumulating. 

k.      number-of-child: The number of children an agent has in current marriage. An agent could have a maximum of 2 children in one marriage. After the agent divorces, this attribute is reset to 0.

l.      not-in-good-health:(true/false) agents' health condition

m.      wait-for-treatment: 0 when the agent is not in bad health. After an agent become unhealthy(not-in-good-health = true) or an infected agent who appears to be healthy takes a regular health check and then is recorded as unhealthy(not-in-good-health = true), they seek treatment. After 4 ticks(two years), they recover. That is, they are not infected, not in bad health and this attribute is reset to 0.

n.      infected-once?:(true/false) whether the agent has been diagnosed and seeked treatment once.

o.      contacts: ids of agents who are linked with me. When an agent is created(born), it creates links with all agents on its neighbor patches and stores their ids in this attribute(a list). This list is updated every tick, as agents could die and cut all their links, so that this list only stores ids of living agents. The length of the list can only decrease.

p. pa-id and ma-id: These two attributes of all agents are set as 99999 when initializing the model. After these agents give births to new agents, the new agents stores the ids of their parents in these attributes.

  

##  3.     PROCESS OVERVIEW AND SCHEDULING 

In each tick, first ask people older than 60 or people who are in bad health to die and cut their links based on certain dying probability. If the dying agent is married, its spouse is automatically divorced. Ask infected people to update infected-time-one-for-six-month(+1). Every year(infected-time-one-for-six-month mod 2 = 0) after a year of infection(infected-time-one-for-six-month = 2), infected people could become sick(not in good health) based on a probability of 5%. People in bad health update wait-for-treatment(+1). When wait-for-treatment reaches 4, the patient recover(infected? = false, infected-time-one-for-six-month = 0 ,wait-for-treatment = 0) but would have infected-once? set to true. If a recovered agent is still married to an infected agent, the recovered agent will still have infected? as "true".

In each tick, only agents who are active-adults(18-45 years old, unmarried and in good health) can move and interact. They find one of active-adults on their neighbor patches after moving and a)decided whether or not to date/interact based on "interactive-rate" b) if decides to interact, update date-id of both agents and decide whether or not to use a condom(condom-using-rate) c) if decides to use a condom, update current risk of both agents, check if one could be infected based on current risk d)if not decides to use a condom, current risks of both agnets are their original risks. Check if one could be infected based on current risk. 50% of chance having a baby. Set the baby's ma-id and pa-id, set its infection status according to its parents and choose vaccine for the baby. e) After interaction/date, decide whether or not to get married. f) if decide to get married, set spouse the value in date-id, set married status to true. If a not infected agent ia married with an infected agent, it is now infected.

The wife(gender = 2) agents, if they are 18-45 years old, in good health and have fewer than 2 children in this marriage, they give birth to a new agent. "number-of-child" of both the parent agents are updated. The newborn then choose vaccine based on chosen strategy and set its infection status according to its parents.

Married agents might divorce based on divorce-rate and reset their marriage status, number-of-child and spouse.

After a year(ticks mod 2 = 0), all agents age up a year.

Every two years(ticks mod 4 = 0), a number of agents based on regular-check-cover-rate*population are chosen to take a health check. All infected agents who appear to be healthy but take this check would be recognized as not in good health and start to seek treatment. 

When each tick ends, date-id of all agents are reset to 99999.


## 4. DESIGN CONCEPTS


-   Basic principles
The basic principle simulates the spread of HPV in a population.


-   Interaction: 
People who are recognized as active-adults could inetract with each other


-   Emergence, Adaptation and prediction
The infection-rate could either increase and decrease when running the model. This is also true for vaccinated-rate.
Newborns are vaccinated or not vaccinated based on "vaccine-strategy-of-newborn" which could influence the vaccinated-rate and further the infection-rate. 
We expect mandatory vaccination would result in everyone being protected by the vaccine and a very low value(even 0) of infection-rate in the end. While anti-vaccine gives the opposite. No one is protected by vaccine any more and the infection-rate is high.

-   Stochasticity: 
People differ in their risk of being infected. They also decide whether or not to date/interact, use a condom, marry, divorce based on the settings in the model(determined in a Bernoulli trial). There are also vaccine strategies of newborn to determine the vaccinated status and risk of newborn. So the spread of virus has certain chance of failing and we see how changes in the settings could affect the results.

-   Objectives
People are either infected or not. They make all their decisions based on for example "condom-using-rate" in the interface. 

-   Sensing, Collectives and Learning
Active adults will act based on whether they could find another active adult on neighbor patches. Social network("contacts") is introduced to the model so that the baby could check its parents' "contacts" to decided whether to take the vaccine if "vaccine-strategy-of-newborn" is set to "lesson-from-family-friend". The baby could "learn" from this family friend who is vaccinated or not in good health(because of  infection) or has been infected once. So either high vaccine cover rate or high infection rate boosts vaccination. If "vaccine-strategy-of-newborn" is set to "one-of-my-parents" or "both-of-my-parents", the baby could "learn" from its parents so that a high vaccine cover rate could further boost vaccination.

-   Observation: The view shows the location of each agent on the environment and their status(active-adult? and infected?). There are two plots that monitor the different results. 

       a.infection-rate
       The percentage of infected people in the total population.

       b.vaccinated-rate
       The percentage of vaccinated people in the total population.



## 5. DETAILS

 Model Setup

When setting up the model, the users decide "density", "initial-patient-rate", "vaccine-strategy-of-newborn" and everything else in the interface. Pressing "setup" would start the initialization. The size of the whole population is the number of patches times density. People are created ranomly on empty patches so they do not overlap each other. Within the whole population, we create patients. The number of patients is the whole population times initial-patient-rate.


Submodels

-   Vaccine-strategy-of-newborn & condom-using-rate & initial-vaccine-rate & regular-check-cover-rate & interactive/marriage/divorce rate:
It is assumed that these rates are the same for everyone in the environment when we set up the model.

-   Die of disease and age
We assume that patient has a probability of dying which equals to 10% after its health condition start to deteriorate. It is also assumed that people over 60 years old could die of age in each tick. The older they are(60-70,70-80,80), the more likely they die. In the model, when a turtle reaches 80 years old, it dies immediately.

-   Active-adult
Only people who are 18-45 years old, not married and in good health could be recognized as an active-adult. Only active adults could move around and date/interact. 

-   Date and condoms
People move around and decide whether or not to date one of the people on its neighbour patches based on interactive-rate. If it decides to interact/date, its and its date's date-id is updated. Then it decides whether to use a condom, if a condom is used, it and its date's current risks are 30% of their original risks. After that, they check if their dates are infected, if one is infected and the other one is not, the healthy agent has a probability of being infected which equals to its current risk. If no condom is used, their risks are still their original risks and one has a proability of being infected by an infected date. They also have 50% of chance of having a baby together when not using a condom. But this baby is not counted in their "number-of-child". The baby records its parents' ids. As long as one of the parent is infected, the baby is infected. The baby also chooses whether or not to be vaccinated based on "vaccine-strategy-of-newborn". If the baby is infected and vaccinated, its original risk is 50 as vaccine does not work as effectively on it as on a not-infected baby.

-   Marriage and giving birth within marriage
After date/interaction, the two people decide whether or not to get married based-on marriage-rate. If they get married, they update their "spouse" and check the infection status of their spouse. We assume that as long as one people in the couple is infected, the other should also be infected. Every six months(one tick), the wife of the married couple who is 18-45 and in good health and has less than two children ("number-of-child") could give birth to a baby. This would cause the couple to update their number-of-child. Like in the dating process, the baby decides whether to be vaccinated and infected based on "vaccine-strategy-of-newborn" and the infection status of its parents. If the baby is infected and vaccinated, its original risk is 50.

-   Divorce
In every tick, the couple decide whether to divorce based on "divorce-rate". If they decide to divorce, they reset their married status to false, "spouse" to 99999 and "number-of child" to 0.

-   Connection
When setting up the model, everyone creates links with others on neighbor patches and store their ids in "contacts". After a people dies, its links with others disappears. In every tick, everyone checks and updates its "contacts" based on its links.

-   Vaccine-strategy-of-newborn and original risk
a. anti-vaccine
No vaccine and risk is set as 100(highest)
b. society
Get vaccinated based on initial-vaccine-rate
If vacciated, set risk 30 and 100 otherwise
c. one-of-my-parents
As long as one of the parents is vaccinated, the baby is vaccinated and its risk is 30. Or it is not vaccinated, and its risk is 100.
d. both-of-my-parents
Only when both of the parents are vaccinated, could the baby be vaccinated and its risk is 30. Or it is not vaccinated, and its risk is 100.
e. lesson-from-family-friend
As long as one of the parents is vaccinated, the baby is vaccinated and its risk is 30. If neither of the parents is vaccinated, a "family friend" is chosen randomly from "contacts" of the parents. If it is vaccinated or not in good health or has infected once, the baby is vaccinated. Or, the baby is not vaccinated(also when parents have no contacts). 
f. mandatory
Vaccination is a must and the risk is 30.


-   Regular check, treatment and recovery
Every two years(four ticks), a number of people would be selected to take a health check. If an agent is infected but has not yet become unhealthy, its health condition is recorded as bad after the health check and then it would start to seek help. After an infected agent's health condition becomes bad, it would also start to seek help. We assume the treatment would take two years as Giuliano and colleagues(2008) found that infection clearance is done after around 18 months after initial positive test but we add six more months to show that people just recovered would be cautious and stop risky interactions for another six months. After the treatment, the agent is recoverd and no longer infected or in bad health but it will be recorded as a person who has been infected once. If the agent is married with an infected agent, and not divorced with it after the treatment, it would be infected.


## 6. LIMITATIONS AND POSSIBLE EXTENSIONS
 
-   	Education level of agents:
You can introduce education level in the model and let agents decide whether or not to be vaccinated or use condoms instead of useing a shared rate. This could further influence "one-of-my-parents" and "both-of-my-parents" in "vaccine-strategy-of-newborn". Furthermore, if an agent is not vaccinated when it was born because of parents' vaccine status, it could decide whether or not to take the vaccine when it turns 18 years old based on its own education level. But, of course, we assume parents' education level would affect the education level of their children.



## RELATED MODELS 

- "Epidemic" in the NetLogo Models Library demonstrates the spread of diseases in a population.


## Citation

Wang et al. (2011) ‘An agent-based approach for modeling dynamics of sexual transmission of HIV/AIDS’, 2011 International Conference on Computer Science and Service System (CSSS), Computer Science and Service System (CSSS), 2011 International Conference on, pp. 2968–2971. doi:10.1109/CSSS.2011.5974829.

World Health Organization (2022) 'Human papillomavirus (HPV) and cervical cancer - WHO'. Retrieved from https://www.who.int/news-room/fact-sheets/detail/cervical-cancer(retrieved on 1st June 2023).

Winer, R.L. et al. (2006) ‘Condom Use and the Risk of Genital Human Papillomavirus Infection in Young Women’, The New England Journal of Medicine, 354(25), pp. 2645–2654. doi:10.1056/NEJMoa053284.

Leval, A. et al. (2013) ‘Quadrivalent human papillomavirus vaccine effectiveness: a Swedish national cohort study’, Journal of the National Cancer Institute, 105(7), pp. 469–474. doi:10.1093/jnci/djt032.

Burlamaqui, J.C.F. et al. (2017) ‘Human Papillomavirus and students in Brazil: an assessment of knowledge of a common infection – preliminary report’, Brazilian Journal of Otorhinolaryngology, 83(2), pp. 120–125. doi:10.1016/j.bjorl.2016.02.006.

Hernandez, B.Y. et al. (2008) ‘Transmission of Human Papillomavirus in Heterosexual Couples’, Emerging Infectious Diseases, 14(6), pp. 888–894. doi:10.3201/eid1406.0706162.

Tsai, P. L. et al. (1993) ‘Possible non-sexual transmission of genital human papillomavirus infections in young women’, European Journal of Clinical Microbiology & Infectious Diseases, 12, pp. 221–223.

Boucher, J.C. et al. (2023) ‘HPV vaccine narratives on Twitter during the COVID-19 pandemic: a social network, thematic, and sentiment analysis’, BMC Public Health, 23(1). doi:10.1186/s12889-023-15615-w.

National Cancer Institute (2021). 'Despite proven safety of HPV
vaccines, more parents have concerns'. Retrieved from https://www.cancer.gov/news-events/cancer-currents-blog/2021/hpv-vaccine-parents-safety-concerns(retrieved on 1st June 2023).

Argyris, Y.A. et al. (2021) ‘The mediating role of vaccine hesitancy between maternal engagement with anti- and pro-vaccine social media posts and adolescent HPV-vaccine uptake rates in the US: The perspective of loss aversion in emotion-laden decision circumstances’, Social Science and Medicine, 282. doi:10.1016/j.socscimed.2021.114043.

Machida, M. and Inoue, S. (2023) ‘Patterns of HPV vaccine hesitancy among catch-up generations in Japan: A descriptive study’, Vaccine, 41(18), pp. 2956–2960. doi:10.1016/j.vaccine.2023.03.061.

Burchell, A.N. et al. (2006) ‘Modeling the Sexual Transmissibility of Human Papillomavirus Infection using Stochastic Computer Simulation and Empirical Data from a Cohort Study of Young Women in Montreal, Canada’, AMERICAN JOURNAL OF EPIDEMIOLOGY, 1 January, pp. 534–543.

Giuliano, A.R. et al. (2008) ‘Age-Specific Prevalence, Incidence, and Duration of Human Papillomavirus Infections in a Cohort of 290 US Men’, The Journal of Infectious Diseases, 198(6), pp. 827–835. doi:10.1086/591095.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>infection-rate</metric>
    <enumeratedValueSet variable="initial-vaccine-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="condom-using-rate">
      <value value="30"/>
      <value value="50"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="marriage-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine-strategy-of-newborn">
      <value value="&quot;society&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interactive-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="divorce-rate">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regular-check-cover-rate">
      <value value="30"/>
      <value value="60"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-patient-rate">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
