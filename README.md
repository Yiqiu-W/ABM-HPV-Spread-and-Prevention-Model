#### ABM-HPV-Spread-and-Prevention-Model
<img width="597" alt="image" src="https://github.com/Yiqiu-W/ABM-HPV-Spread-and-Prevention-Model/assets/164640614/f9e97d15-454e-4603-bd50-e3c12c2e3bc9">

#### 1.     PURPOSE AND PATTERNS
##### This model is inspired by the research on AIDS done by Wang and colleagues(2011) using Repast Simphony1.2. In their model, they introduced sex, age, maximum age, partner, health status, condom using rate, infected time, being diagnosed or not, married status, as well as the number of people a patient could infect. 

##### In this model about the spread and prevention of HPV, HPV vaccine is introduced. There are also different vaccine injection  strategies for newborns. Infected agents who are not in good health could die of disease and all agents could die of age. The health condition of infected agents could deteriorate and then they would seek help. Regular health check provided by the government is also introduced but it has a cover rate so if infected agents who are still in good health is chosen to take one health check, they are immediately recognized as not in good health and start treatment. Social network is included in the model so most agents have a certain number of contacts. If "vaccine-strategy-of-newborn" is set to "lesson-from-family-friend", the newborn will be vaccinated as long as there is one of its parent vaccinated. Otherwise, it checks one of its parents' contacts, if that person is vaccinated or not in good health or has been infected once, the baby will be vacccinated. Otherwise, the newborn will not be vaccinated. 

##### This model simulates the spread of HPV(human papillomavirus) in a population given different settings.

##### According to World Health Organization(2022), An HPV infection is caused by the human papillomavirus. While many infections do not lead to severe consequences on health, an infection could result in warts or precancerous lesions. These lesions increase the risk of cancer of the cervix, vulva, vagina, penis and other body parts based on where the lesions happen. HPV is the main cause of cervical cancer.

##### "condom-using-rate", "initial-vaccine-rate", "regular-check-cover-rate", "interactive-rate", "marriage-rate", "divorce-rate" and "vaccine-strategy-of-newborn" is set before the model start to run.

##### The model is designed to test how different vaccine strategy for newborn as well as different "condom-using-rate" and other variables could influence the infection rate and the vaccinated rate of a population in 50 years to find effective measures that could be taken to contain the spread of HPV. It has been proved that people who regularly use condoms during sexual contacts is 70% less likely to be infected than those who seldom use condoms(Winer et al. 2006). The effectiveness of HPV vaccine is around 70% if the injection is done in a relatively young age(first dose before age 20)(Leval et al. 2013). Although HPV is most commonly known for transmition through sexual contacts, baby whose mother has vaginal/vulvar condyloma is over 200 times more likely to be infected with HPV through vertical transmission than those has healthy mothers(Burlamaqui et al. 2017). Apart from these modes of transmission,transmission between the hands and genitals(Hernandez et al. 2008), through shared objects(Tsai et al. 1993) have also been proven. So in this model, we assume people who perform sexual behaviours have different risk levels based on whether or not they are vaccinated and use condoms. We also assume that married couples always infect each other and parents always infect children considering not only do married couples perform sexual behaviours without condoms sometimes which increases their risk of being infected, and mothers infect babies while giving birth, but also interact quite often and probably share items as a family.

##### Online interaction and the spread of misinformation especially during the COVID-19 pandemic as well as anti-vaccine movements have become an obstacle of promoting HPV vaccine as it increased parents’ concern about HPV vaccines(Boucher et al. 2023; National Cancer Institute 2021; Argyris et al. 2021). Reports on Japanese media about vaccine-related adverse events has lowered the willingness of vaccination and even resulted in the government suspending the recommendation of the vaccine(Machida and Inoue 2023).

##### To observe pattern of HPV spread and vaccine injection in 50 years, two plots are created based on the number of infected people over the whole population(infection-rate) and the number of vaccinated people over the whole population(vaccinated-rate).


#### 2.   ENTITIES, STATE VARIABLES AND SCALES
##### The environment consists of 12*12 patches. All global variables such as density, vaccine-strategy-of-newborn and the seven rates could be changed before setting up the model and are constant through out the simulation. One tick in the model stands for six months in reality and the model will stop when ticks reach 100, which is 50  years after start of the simulation.

 
##### There is only one kind of agents in the model. The following are their attributes:

##### a. 	age: a random number ranging from 0 to 80. When the model is set up, differnt age values are assigned to every agent based on a positive skewed distribution agemean= 25    sd=7    skewness_factor=3

##### (random-normal agemean sd) + ((random-normal agemean sd) - agemean) * skewness_factor

##### Note: When the model initializes, the minimum age is 14 and the maximum age is 50. So age value lower than 14 is set 14 and age value higher than 50 is set 50.


##### b. 	gender: This attribute record a value equals to 1 or 2 with 2 standing for female. The probability of being a male is 45% and female 55%. This probabilty also holds for newborn.

##### c. 	active-adult?: (true/false) Only when an agent is 18-45 years old, unmarried and in good health can it record "true" in this attribute. This attribute is updated in every tick.

##### d. 	married?:(true/false)marriage status

##### e. 	date-id: This attribute is set as 99999 (to avoid confusion with 0) when an agent is created(born). When active-adults decide to date, they update the value to the id of their dates. This attribute is reset to 99999 in each tick.

##### f.      spouse: This attribute is set as 99999 (to avoid confusion with 0) when an agent is created(born). After dating, if an agent decides to marry its date, it and its date set value based on date-ids they just updated. If an agent decides to divorce, it and its spouse both reset this value to 99999. 

##### g.      infected?: whether or not the agent is infected with HPV

##### h.      infected-time-one-for-six-month: 0 when the agent is not infected. 1 stands for six months. After an agent is infected, this value adds 1 in every tick. After one year of being infected(when this attribute = 2), the agent has a probability of 10% of having bad health every year(when this attribute = 2/4/6...). After an infected agent recovers, this attribute is reset to 0. 

##### i.      vaccinated?: whether or not this agent has been vaccinated

##### j.      risk: (30/50/100) For a not infected agent, this attribute is 100(not protected) if it has not been vaccinated and 30(highly protected) if it has been vaccinated. For an infected agent, the attribute is still 100 if it has not been vaccinated but 50(not-so-protected) if it has been vaccinated because we assume that the vaccine does not work on it as effectively as on not infected agents. The highest risk is set to be 100 instead of 40, which is suggested as the risk of being infected per sexual behaviour(Burchell et al. 2006) because each tick stands for six months, and when agents are dating we expect that during a six-month relationship the two agents would have other physical contacts besides sexual contacts so the risk is accumulating. 

##### k.      number-of-child: The number of children an agent has in current marriage. An agent could have a maximum of 2 children in one marriage. After the agent divorces, this attribute is reset to 0.

##### l.      not-in-good-health:(true/false) agents' health condition

##### m.      wait-for-treatment: 0 when the agent is not in bad health. After an agent become unhealthy(not-in-good-health = true) or an infected agent who appears to be healthy takes a regular health check and then is recorded as unhealthy(not-in-good-health = true), they seek treatment. After 4 ticks(two years), they recover. That is, they are not infected, not in bad health and this attribute is reset to 0.

##### n.      infected-once?:(true/false) whether the agent has been diagnosed and seeked treatment once.

##### o.      contacts: ids of agents who are linked with me. When an agent is created(born), it creates links with all agents on its neighbor patches and stores their ids in this attribute(a list). This list is updated every tick, as agents could die and cut all their links, so that this list only stores ids of living agents. The length of the list can only decrease.

##### p. pa-id and ma-id: These two attributes of all agents are set as 99999 when initializing the model. After these agents give births to new agents, the new agents stores the ids of their parents in these attributes.

  

####  3.     PROCESS OVERVIEW AND SCHEDULING 

##### In each tick, first ask people older than 60 or people who are in bad health to die and cut their links based on certain dying probability. If the dying agent is married, its spouse is automatically divorced. Ask infected people to update infected-time-one-for-six-month(+1). Every year(infected-time-one-for-six-month mod 2 = 0) after a year of infection(infected-time-one-for-six-month = 2), infected people could become sick(not in good health) based on a probability of 5%. People in bad health update wait-for-treatment(+1). When wait-for-treatment reaches 4, the patient recover(infected? = false, infected-time-one-for-six-month = 0 ,wait-for-treatment = 0) but would have infected-once? set to true. If a recovered agent is still married to an infected agent, the recovered agent will still have infected? as "true".

##### In each tick, only agents who are active-adults(18-45 years old, unmarried and in good health) can move and interact. They find one of active-adults on their neighbor patches after moving and a)decided whether or not to date/interact based on "interactive-rate" b) if decides to interact, update date-id of both agents and decide whether or not to use a condom(condom-using-rate) c) if decides to use a condom, update current risk of both agents, check if one could be infected based on current risk d)if not decides to use a condom, current risks of both agnets are their original risks. Check if one could be infected based on current risk. 50% of chance having a baby. Set the baby's ma-id and pa-id, set its infection status according to its parents and choose vaccine for the baby. e) After interaction/date, decide whether or not to get married. f) if decide to get married, set spouse the value in date-id, set married status to true. If a not infected agent ia married with an infected agent, it is now infected.

##### The wife(gender = 2) agents, if they are 18-45 years old, in good health and have fewer than 2 children in this marriage, they give birth to a new agent. "number-of-child" of both the parent agents are updated. The newborn then choose vaccine based on chosen strategy and set its infection status according to its parents.

##### Married agents might divorce based on divorce-rate and reset their marriage status, number-of-child and spouse.

##### After a year(ticks mod 2 = 0), all agents age up a year.

##### Every two years(ticks mod 4 = 0), a number of agents based on regular-check-cover-rate*population are chosen to take a health check. All infected agents who appear to be healthy but take this check would be recognized as not in good health and start to seek treatment. 

##### When each tick ends, date-id of all agents are reset to 99999.


#### 4. DESIGN CONCEPTS


##### -   Basic principles
##### The basic principle simulates the spread of HPV in a population.


##### -   Interaction: 
##### People who are recognized as active-adults could inetract with each other


##### -   Emergence, Adaptation and prediction
##### The infection-rate could either increase and decrease when running the model. This is also true for vaccinated-rate.Newborns are vaccinated or not vaccinated based on "vaccine-strategy-of-newborn" which could influence the vaccinated-rate and further the infection-rate. We expect mandatory vaccination would result in everyone being protected by the vaccine and a very low value(even 0) of infection-rate in the end. While anti-vaccine gives the opposite. No one is protected by vaccine any more and the infection-rate is high.

##### -   Stochasticity: 
##### People differ in their risk of being infected. They also decide whether or not to date/interact, use a condom, marry, divorce based on the settings in the model(determined in a Bernoulli trial). There are also vaccine strategies of newborn to determine the vaccinated status and risk of newborn. So the spread of virus has certain chance of failing and we see how changes in the settings could affect the results.

##### -   Objectives
##### People are either infected or not. They make all their decisions based on for example "condom-using-rate" in the interface. 

##### -   Sensing, Collectives and Learning
##### Active adults will act based on whether they could find another active adult on neighbor patches. Social network("contacts") is introduced to the model so that the baby could check its parents' "contacts" to decided whether to take the vaccine if "vaccine-strategy-of-newborn" is set to "lesson-from-family-friend". The baby could "learn" from this family friend who is vaccinated or not in good health(because of  infection) or has been infected once. So either high vaccine cover rate or high infection rate boosts vaccination. If "vaccine-strategy-of-newborn" is set to "one-of-my-parents" or "both-of-my-parents", the baby could "learn" from its parents so that a high vaccine cover rate could further boost vaccination.

##### -   Observation: The view shows the location of each agent on the environment and their status(active-adult? and infected?). There are two plots that monitor the different results. 

#####       a.infection-rate
#####       The percentage of infected people in the total population.

#####       b.vaccinated-rate
#####       The percentage of vaccinated people in the total population.



#### 5. DETAILS

##### Model Setup

##### When setting up the model, the users decide "density", "initial-patient-rate", "vaccine-strategy-of-newborn" and everything else in the interface. Pressing "setup" would start the initialization. The size of the whole population is the number of patches times density. People are created ranomly on empty patches so they do not overlap each other. Within the whole population, we create patients. The number of patients is the whole population times initial-patient-rate.


##### Submodels

##### -   Vaccine-strategy-of-newborn & condom-using-rate & initial-vaccine-rate & regular-check-cover-rate & interactive/marriage/divorce rate:
##### It is assumed that these rates are the same for everyone in the environment when we set up the model.

##### -   Die of disease and age
##### We assume that patient has a probability of dying which equals to 10% after its health condition start to deteriorate. It is also assumed that people over 60 years old could die of age in each tick. The older they are(60-70,70-80,80), the more likely they die. In the model, when a turtle reaches 80 years old, it dies immediately.

##### -   Active-adult
##### Only people who are 18-45 years old, not married and in good health could be recognized as an active-adult. Only active adults could move around and date/interact. 

##### -   Date and condoms
##### People move around and decide whether or not to date one of the people on its neighbour patches based on interactive-rate. If it decides to interact/date, its and its date's date-id is updated. Then it decides whether to use a condom, if a condom is used, it and its date's current risks are 30% of their original risks. After that, they check if their dates are infected, if one is infected and the other one is not, the healthy agent has a probability of being infected which equals to its current risk. If no condom is used, their risks are still their original risks and one has a proability of being infected by an infected date. They also have 50% of chance of having a baby together when not using a condom. But this baby is not counted in their "number-of-child". The baby records its parents' ids. As long as one of the parent is infected, the baby is infected. The baby also chooses whether or not to be vaccinated based on "vaccine-strategy-of-newborn". If the baby is infected and vaccinated, its original risk is 50 as vaccine does not work as effectively on it as on a not-infected baby.

##### -   Marriage and giving birth within marriage
#####  After date/interaction, the two people decide whether or not to get married based-on marriage-rate. If they get married, they update their "spouse" and check the infection status of their spouse. We assume that as long as one people in the couple is infected, the other should also be infected. Every six months(one tick), the wife of the married couple who is 18-45 and in good health and has less than two children ("number-of-child") could give birth to a baby. This would cause the couple to update their number-of-child. Like in the dating process, the baby decides whether to be vaccinated and infected based on "vaccine-strategy-of-newborn" and the infection status of its parents. If the baby is infected and vaccinated, its original risk is 50.

##### -   Divorce
##### In every tick, the couple decide whether to divorce based on "divorce-rate". If they decide to divorce, they reset their married status to false, "spouse" to 99999 and "number-of child" to 0.

##### -   Connection
##### When setting up the model, everyone creates links with others on neighbor patches and store their ids in "contacts". After a people dies, its links with others disappears. In every tick, everyone checks and updates its "contacts" based on its links.

##### -   Vaccine-strategy-of-newborn and original risk
##### a. anti-vaccine
##### No vaccine and risk is set as 100(highest)

##### b. society
##### Get vaccinated based on initial-vaccine-rate
##### If vacciated, set risk 30 and 100 otherwise

##### c. one-of-my-parents
##### As long as one of the parents is vaccinated, the baby is vaccinated and its risk is 30. Or it is not vaccinated, and its risk is 100.
##### d. both-of-my-parents
##### Only when both of the parents are vaccinated, could the baby be vaccinated and its risk is 30. Or it is not vaccinated, and its risk is 100.

##### e. lesson-from-family-friend
##### As long as one of the parents is vaccinated, the baby is vaccinated and its risk is 30. If neither of the parents is vaccinated, a "family friend" is chosen randomly from "contacts" of the parents. If it is vaccinated or not in good health or has infected once, the baby is vaccinated. Or, the baby is not vaccinated(also when parents have no contacts). 

##### f. mandatory
##### Vaccination is a must and the risk is 30.


##### -   Regular check, treatment and recovery
##### Every two years(four ticks), a number of people would be selected to take a health check. If an agent is infected but has not yet become unhealthy, its health condition is recorded as bad after the health check and then it would start to seek help. After an infected agent's health condition becomes bad, it would also start to seek help. We assume the treatment would take two years as Giuliano and colleagues(2008) found that infection clearance is done after around 18 months after initial positive test but we add six more months to show that people just recovered would be cautious and stop risky interactions for another six months. After the treatment, the agent is recoverd and no longer infected or in bad health but it will be recorded as a person who has been infected once. If the agent is married with an infected agent, and not divorced with it after the treatment, it would be infected.

#
#
#### 6. LIMITATIONS AND POSSIBLE EXTENSIONS
 
##### -   	Education level of agents:
##### You can introduce education level in the model and let agents decide whether or not to be vaccinated or use condoms instead of useing a shared rate. This could further influence "one-of-my-parents" and "both-of-my-parents" in "vaccine-strategy-of-newborn". Furthermore, if an agent is not vaccinated when it was born because of parents' vaccine status, it could decide whether or not to take the vaccine when it turns 18 years old based on its own education level. But, of course, we assume parents' education level would affect the education level of their children.



#### RELATED MODELS 

##### - "Epidemic" in the NetLogo Models Library demonstrates the spread of diseases in a population.


####  Citation

##### Wang et al. (2011) ‘An agent-based approach for modeling dynamics of sexual transmission of HIV/AIDS’, 2011 International Conference on Computer Science and Service System (CSSS), Computer Science and Service System (CSSS), 2011 International Conference on, pp. 2968–2971. doi:10.1109/CSSS.2011.5974829.

##### World Health Organization (2022) 'Human papillomavirus (HPV) and cervical cancer - WHO'. Retrieved from https://www.who.int/news-room/fact-sheets/detail/cervical-cancer(retrieved on 1st June 2023).

##### Winer, R.L. et al. (2006) ‘Condom Use and the Risk of Genital Human Papillomavirus Infection in Young Women’, The New England Journal of Medicine, 354(25), pp. 2645–2654. doi:10.1056/NEJMoa053284.

##### Leval, A. et al. (2013) ‘Quadrivalent human papillomavirus vaccine effectiveness: a Swedish national cohort study’, Journal of the National Cancer Institute, 105(7), pp. 469–474. doi:10.1093/jnci/djt032.

##### Burlamaqui, J.C.F. et al. (2017) ‘Human Papillomavirus and students in Brazil: an assessment of knowledge of a common infection – preliminary report’, Brazilian Journal of Otorhinolaryngology, 83(2), pp. 120–125. doi:10.1016/j.bjorl.2016.02.006.

##### Hernandez, B.Y. et al. (2008) ‘Transmission of Human Papillomavirus in Heterosexual Couples’, Emerging Infectious Diseases, 14(6), pp. 888–894. doi:10.3201/eid1406.0706162.

##### Tsai, P. L. et al. (1993) ‘Possible non-sexual transmission of genital human papillomavirus infections in young women’, European Journal of Clinical Microbiology & Infectious Diseases, 12, pp. 221–223.

##### Boucher, J.C. et al. (2023) ‘HPV vaccine narratives on Twitter during the COVID-19 pandemic: a social network, thematic, and sentiment analysis’, BMC Public Health, 23(1). doi:10.1186/s12889-023-15615-w.

##### National Cancer Institute (2021). 'Despite proven safety of HPV vaccines, more parents have concerns'. Retrieved from https://www.cancer.gov/news-events/cancer-currents-blog/2021/hpv-vaccine-parents-safety-concerns(retrieved on 1st June 2023).

##### Argyris, Y.A. et al. (2021) ‘The mediating role of vaccine hesitancy between maternal engagement with anti- and pro-vaccine social media posts and adolescent HPV-vaccine uptake rates in the US: The perspective of loss aversion in emotion-laden decision circumstances’, Social Science and Medicine, 282. doi:10.1016/j.socscimed.2021.114043.

##### Machida, M. and Inoue, S. (2023) ‘Patterns of HPV vaccine hesitancy among catch-up generations in Japan: A descriptive study’, Vaccine, 41(18), pp. 2956–2960. doi:10.1016/j.vaccine.2023.03.061.

##### Burchell, A.N. et al. (2006) ‘Modeling the Sexual Transmissibility of Human Papillomavirus Infection using Stochastic Computer Simulation and Empirical Data from a Cohort Study of Young Women in Montreal, Canada’, AMERICAN JOURNAL OF EPIDEMIOLOGY, 1 January, pp. 534–543.

##### Giuliano, A.R. et al. (2008) ‘Age-Specific Prevalence, Incidence, and Duration of Human Papillomavirus Infections in a Cohort of 290 US Men’, The Journal of Infectious Diseases, 198(6), pp. 827–835. doi:10.1086/591095.
