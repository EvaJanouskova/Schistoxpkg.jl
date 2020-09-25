var documenterSearchIndex = {"docs":
[{"location":"#Schistoxpkg.jl-1","page":"Home","title":"Schistoxpkg.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"A package to run an individual based mode of a schistosomiasis outbreak based on original code from this paper. Generally people uptake larvae based on a contact rate defined by their age, along with some predisposition which is chosen from a gamma distribution with mean 1, but some specified level of variance.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"All parameters are stored in the parameters.jl file in the src folder.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The model has a parameter which defines the time step that we take forward each time. Several functions are then called each time step which simulate the run of the outbreak. This is repeated until we reach a specified number of steps, usually corresponding to stepping forward a chosen number of years into the future.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The standard approach is given by the following set of processes which all have their own function to execute them. Each time step we advance the time of the simulation by the length of the time step and also add this time step to the age of each individual. There is a chosen period at which contact rates are updated for each individual, where we check if someone has aged into a different age bracket, resulting if their level of contact has changed.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"We then calculate the total number of worms within each individual and the number of pairs of worms a person has. These numbers are used to calculate how many eggs someone will produce. The number of eggs is chosen from a poisson distribution with mean equal to the number of worm pairs multiplied by the max fecundity parameter and then multiplied by an exponential function which calculates the density dependent reduction in eggs produced, λ wp exp(-wp z). We then kill the worms within human hosts at a given rate, which is based on average worm lifespan.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Eggs are then hatched into the environment, with egg release dependent on the age specific contact rate of each individual. Humans are given an age of death when they are born, which is based on some chosen death rates for each age group. We check each time step if anyone has outlived their age of death and if they have, they are then removed from the population. Cercariae from the environment are then uptaken to each surviving individual based on their predisposition and contact rate. These immediately become worms within the human host.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"We then perform any interventions which are due to take place at this point in time after which we will cull the miracidia and cercariae in the environment by a chosen percentage. After this we will add births to the population which occur at some specified rate.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"There are other versions of this basic approach, where we don't age the population or include births and deaths and also where the population is aged but every death is simply matched with a birth, resulting in the population being kept constant.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Modules = [Schistoxpkg]","category":"page"},{"location":"#Schistoxpkg.cercariae_uptake-NTuple{14,Any}","page":"Home","title":"Schistoxpkg.cercariae_uptake","text":"cercariae_uptake(env_miracidia, env_cercariae, time_step, contact_rate,\n    community, community_contact_rate, female_worms, male_worms,\n    predisposition, age_contact_rate, vac_status, vaccine_effectiveness, human_cercariae_prop,\n    miracidia_maturity_time)\n\nuptake cer\n\n\n\n\n\n","category":"method"},{"location":"#Schistoxpkg.create_population-NTuple{16,Any}","page":"Home","title":"Schistoxpkg.create_population","text":"create_population\n\nThis will create the initial human population with randomly chosen age, and gender.      Predisposition is taken to be gamma distributed.      There is also a male and female adjustment to predisposition adjusting for gender specific behaviour          In addition to this, it will create the initial miracidia environment vector\n\n\n\n\n\n","category":"method"},{"location":"#Schistoxpkg.create_population_specified_ages-NTuple{19,Any}","page":"Home","title":"Schistoxpkg.create_population_specified_ages","text":"create_population_specified_ages\n\nThis will create the initial human population with an age distribution specified by the spec_ages variable Predisposition is taken to be gamma distributed. There is also a male and female adjustment to predisposition adjusting for gender specific behaviour In addition to this, it will create the initial miracidia environment vector\n\n\n\n\n\n","category":"method"},{"location":"#Schistoxpkg.egg_production-NTuple{6,Any}","page":"Home","title":"Schistoxpkg.egg_production","text":"egg_production(eggs, max_fecundity, r, worm_pairs,\n                    density_dependent_fecundity, time_step)\n\nfunction to produce eggs for individuals, dependent on how many worms they have         and the max fecundity and density dependent fecundity of the population\n\n\n\n\n\n","category":"method"},{"location":"#Schistoxpkg.update_contact_rate-Tuple{Any,Any,Any}","page":"Home","title":"Schistoxpkg.update_contact_rate","text":"update_contact_rate(ages, age_contact_rate, contact_rates_by_age)\n\nfunction to update the contact rate of individuals in the population. This is necessary     as over time when people age, they will move through different age groups which have     different contact rates\n\n\n\n\n\n","category":"method"},{"location":"#Schistoxpkg.worm_maturity-NTuple{5,Any}","page":"Home","title":"Schistoxpkg.worm_maturity","text":"worm_maturity(female_worms, male_worms, worm_stages,\n    average_worm_lifespan, time_step)\n\nfunction to kill worms, and if there is more than one stage for worm life,         to update how many worms are in each stage\n\n\n\n\n\n","category":"method"}]
}
