using Schistoxpkg
using Test
using Distributions
using Random
using JLD



# filename to save population in =#
# filename = "equ_runs_1.jld"
N = 1000
max_age = 100
initial_worms = 10
time_step = 10
worm_stages = 1
female_factor = 1
male_factor = 1
contact_rate = 0.03
ages_per_index = 5

# if more than one community, then specify how many here
#N_communities = 3
N_communities = 1

# next parameter is the relative probabilities of being in each community
# if entries are all equal, then all communities are equally likely and will
# be roughly the same size
#community_probs = [1,1,1]
community_probs = 1

# community_contact_rate = [1,1,1]
community_contact_rate = 1

# parameter for proportion of people who are given mda who will take it
mda_adherence = .9
mda_access = .9

heavy_burden_threshold = 16
# number of days after which miracidia become cercariae
miracidia_maturity_time = 24 # for S. mansoni
# miracidia_maturity_time = 21 # for S. haemotobium

env_cercariae = 0
initial_miracidia = 50000*N/1000
init_env_cercariae = 50000*N/1000
initial_miracidia_days = trunc(Int,ceil(miracidia_maturity_time/time_step, digits = 0))

# how long to run simulation for
number_years_equ = 200

max_fecundity = 0.34  # for S. mansoni [Toor et al JID paper SI]
#max_fecundity = 0.3  # for S. haematobium [Toor et al JID paper SI]

density_dependent_fecundity = 0.0007 # for S. mansoni [Toor et al JID paper SI]
#density_dependent_fecundity = 0.0006 # for S. haematobium [Toor et al JID paper SI]

r = 0.03 # aggregation parameter for negative binomial for egg production
num_time_steps_equ = trunc(Int, 365*number_years_equ / time_step)

# human birth rate
birth_rate = 28*time_step/(1000*365)

average_worm_lifespan = 5.7 # years for S. mansoni [Toor et al JID paper SI]
#average_worm_lifespan = 4 # years for S. haematobium [Toor et al JID paper SI]

# this is the aggregation parameter for the predisposition
predis_aggregation = 0.24
predis_weight = 1

# what proportion of miracidias and cercariae survive each round
env_miracidia_survival_prop = 1/2
env_cercariae_survival_prop = 1/2
mda_coverage = 0.8 # proportion of target age group reached by mda
mda_round = 0

# proportion of cercariae which can infect humans
human_cercariae_prop = 1

# gamma distribution for Kato-Katz method
gamma_k = Gamma(0.87,1/0.87)

vaccine_effectiveness = 0.95
num_sims = 1

# record the state of the population this often in years
record_frequency = 1/24

#= this is the number of thousands of people in 5 year (0-4, 5-9,...) intervals in Kenya
and will be used to give a specified age structure when we run to equilibrium =#
spec_ages = 7639, 7082, 6524, 5674, 4725, 4147, 3928, 3362,
            2636, 1970, 1468, 1166, 943, 718, 455, 244

#= number of deaths per 1000 individuals by age
    first entry is for under 1's, then for 5 year intervals from then on =#


death_prob_by_age = [0.0656, 0.0093, 0.003, 0.0023, 0.0027, 0.0038, 0.0044, 0.0048, 0.0053,
                                                0.0065, 0.0088, 0.0106, 0.0144, 0.021, 0.0333, 0.0529, 0.0851, 0.1366, 0.2183, 0.2998 , 0.3698, 1]

ages_for_deaths = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60,
                                              65, 70, 75, 80, 85, 90, 95, 100, 110]

use_kato_katz = 0
kato_katz_par = 0.87
drug_efficacy = 0.863
scenario = "moderate "
@testset "update_contact_rate" begin
    @test isapprox(update_contact_rate([5,10,3], [0,0,0], [1,2,3,4,5,6,7,8,9,10,11,12]), [6,11,4])
end



@testset "miracidia_death" begin
    @test miracidia_death([1000,1421,43523,55],1/2) == [1000,1421,43523,28]
end


@testset "miracidia_death" begin
    @test miracidia_death([1000,1421,43523,55],1/3) == [1000,1421,43523,18]
end



@testset "cercariae_death" begin
    @test cercariae_death(1000,1/2,1) == 500
end


@testset "cercariae_death" begin
    @test cercariae_death(1000,1/3,1) == 333
end


@testset "worm_pairs" begin
    @test isapprox(calculate_worm_pairs([[1,3],[17,0],[400,12312]],[[100,3000],[1,6],[1,1]]),[4,7,2] )
end

@testset "total_worms" begin
    @test isapprox(calculate_total_worms([[1,3],[17,0],[400,1]],[[10,30],[1,6],[1,1]])[1], [4,17,401])
end


@testset "total_worms" begin
    @test isapprox(calculate_total_worms([[1,3],[17,0],[400,1]],[[10,30],[1,6],[1,1]])[2], [40,7,2])
end


time_step = 10

death_prob_by_age = [0.0656, 0.0093, 0.003, 0.0023, 0.0027, 0.0038, 0.0044, 0.0048, 0.0053,
                                                0.0065, 0.0088, 0.0106, 0.0144, 0.021, 0.0333, 0.0529, 0.0851, 0.1366, 0.2183, 0.2998 , 0.3698, 1]

ages_for_deaths = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60,
                                              65, 70, 75, 80, 85, 90, 95, 100, 110]

@testset "gen_ages_and_deaths" begin
    @test generate_ages_and_deaths(1, [1.01,2.3,3.1,4.2,5.3], [2.1,1.2,4.3,2.3,6.0], death_prob_by_age, ages_for_deaths, time_step)[1][1] == 1.01 + time_step/365
end


@testset "gen_ages_and_deaths" begin
    @test generate_ages_and_deaths(1, [1.01,2.3,3.1,4.2,5.3], [2.1,1.2,4.3,2.3,6.0], death_prob_by_age, ages_for_deaths, time_step)[1][end-1] == time_step/365
end




@test_throws ErrorException("max_age must be greater than 60") make_age_contact_rate_array(10, "high adult", [], [])

@testset "make_age_contact_rate_array(max_age,scenario)" begin
    @test contact_rates_by_age = make_age_contact_rate_array(max_age, scenario, [1,2,3], [3,5,6])[end] == 6
end

@testset "make_age_contact_rate_array(max_age,scenario)" begin
    @test make_age_contact_rate_array(100, "high adult", [], [])[1] == 0.01
end

@testset "make_age_contact_rate_array(max_age, scenario)" begin
    @test make_age_contact_rate_array(100, "high adult", [], [])[100] == 0.12
end

@testset "make_age_contact_rate_array(max_age, scenario)" begin
    @test make_age_contact_rate_array(100, "low adult", [], [])[100] == 0.02
end

@testset "make_age_contact_rate_array(max_age, scenario)" begin
    @test make_age_contact_rate_array(100, "moderate adult", [], [])[100] == 0.06
end
time_step = 10
human_cercariae = [[4],[5],[6],[7],[8]]
env_miracidia = [10, 10, 10, 10, 1]
env_cercariae = 100
contact_rate = 0.01
predisposition  = [0.1, 0.21, 1.4, 3.1, 100]
age_contact_rate = [0.0, 0.06, 0.12, 0.02, 0.06]
vac_status = [0,0,0,0,0]
vaccine_effectiveness = 0.95
community = 1,2,3,4,1
community_contact_rate = 1,1,1,0,1
female_worms= [[1,1], [2,1], [2,4],[3,1], [2,4]]
male_worms= [[1,1], [2,1], [2,5],[2,1], [2,4]]

@testset "cercariae_uptake(max_age, scenario)" begin
    @test isapprox(cercariae_uptake(copy( env_miracidia), copy(env_cercariae), copy(time_step), copy(contact_rate),
    community, community_contact_rate, copy(female_worms), copy(male_worms),
        copy(predisposition), copy(age_contact_rate), copy(vac_status), copy(vaccine_effectiveness), 1, 24)[2],  [10, 10, 10, 1])
end

time_step = 10
human_cercariae = [[4],[5],[6],[7],[8]]
env_miracidia = [10, 10, 10, 10, 1]
env_cercariae = 100
contact_rate = 0.01
predisposition  = [0.1, 0.21, 1.4, 3.1, 100]
age_contact_rate = [0.0, 0.06, 0.12, 0.02, 0.06]
vac_status = [0,0,0,0,0]
vaccine_effectiveness = 0.95

@testset "cercariae_uptake" begin
    @test isapprox(cercariae_uptake(copy( env_miracidia), copy(env_cercariae), copy(time_step), copy(contact_rate),
    community, community_contact_rate, copy(female_worms), copy(male_worms),
        copy(predisposition), copy(age_contact_rate), copy(vac_status), copy(vaccine_effectiveness),1,24)[3][1][2],  1)
end


time_step = 10
human_cercariae = [[4],[5],[6],[7],[8]]
env_miracidia = [10, 10, 10, 10, 1]
env_cercariae = 100
contact_rate = 0.01
predisposition  = [0.1, 0.21, 1.4, 3.1, 100]
age_contact_rate = [0.0, 0.06, 0.12, 0.02, 0.06]
vac_status = [0,0,0,0,0]
vaccine_effectiveness = 0.95

@testset "cercariae_uptake" begin
    @test cercariae_uptake(copy( env_miracidia), copy(env_cercariae), copy(time_step), copy(contact_rate),
    community, community_contact_rate, copy(female_worms), copy(male_worms),
        copy(predisposition), copy(age_contact_rate), copy(vac_status), copy(vaccine_effectiveness),1,24)[3][5][2] >0
end


time_step = 10
human_cercariae = [[4],[5],[6],[7],[8]]
env_miracidia = [10, 10, 10, 10, 1]
env_cercariae = 100
contact_rate = 0.01
predisposition  = [0.1, 0.21, 1.4, 3.1, 100]
age_contact_rate = [0.0, 0.06, 0.12, 0.02, 0.06]
vac_status = [0,0,0,0,1]
vaccine_effectiveness = 1

@testset "cercariae_uptake" begin
    @test cercariae_uptake(copy( env_miracidia), copy(env_cercariae), copy(time_step), copy(contact_rate),
    community, community_contact_rate, copy(female_worms), copy(male_worms),
        copy(predisposition), copy(age_contact_rate), copy(vac_status), copy(vaccine_effectiveness),1,1)[3][5][2] == 4
end

female_worms = [[10000,200000],[200000,0]]
male_worms = [[10000,200000],[200000,0]]
worm_stages = 2
average_worm_lifespan = 5.7

@testset "worm_maturity" begin
    @test worm_maturity(female_worms, male_worms, worm_stages, average_worm_lifespan, time_step)[1][1][2] < 200000
end

@testset "worm_maturity" begin
    @test worm_maturity(female_worms, male_worms, worm_stages, average_worm_lifespan, time_step)[1][2][2] > 00
end


@testset "worm_maturity" begin
    @test worm_maturity(female_worms, male_worms, worm_stages, average_worm_lifespan, time_step)[2][1][1] < 10000
end

@testset "worm_maturity" begin
    @test worm_maturity(female_worms, male_worms, worm_stages, average_worm_lifespan, time_step)[2][2][1] < 200000
end



@testset "miracidia_production" begin
    @test miracidia_production([1,2,3],[2,4,1], 10, [1,1,1],[1,1,2], [1,2,3])[1] == 2
end


@testset "miracidia_production" begin
    @test miracidia_production([1,2,3],[2,4,1], 10, [1,1,1],[1,1,1.2], [1,2,3])[end] == 6
end


@testset "miracidia_production" begin
    @test miracidia_production([1,2,3],[2,4,1], 10, [1,1,1],[0,1,0], [1,2,3])[end] == 2
end


@testset "miracidia_production" begin
    @test miracidia_production([1,2,3],[2,4,1], 10, [1,1,1],[0.5,0.5,0.5], [1,2,3])[end] == 6
end






vaccine_info = []
push!(vaccine_info, vaccine_information(0.75, 4, 16, [0,1], 3, 13))
push!(vaccine_info, vaccine_information(0.4, 17, 110, [0,1], 3, 17))

@testset "update_vaccine" begin
    @test update_vaccine(vaccine_info, 1)[1] == 0.4
end

@testset "update_vaccine" begin
    @test update_vaccine(vaccine_info, 1)[2] == 17
end

@testset "update_vaccine" begin
    @test update_vaccine(vaccine_info, 1)[3] ==110
end

@testset "update_vaccine" begin
    @test update_vaccine(vaccine_info, 1)[4] ==17
end

@testset "update_vaccine" begin
    @test update_vaccine(vaccine_info, 1)[5] ==[0,1]
end


@testset "update_vaccine" begin
    @test update_vaccine(vaccine_info, 100)[4] == Inf
end


@testset "death_of_human" begin
    @test death_of_human([2,4], [0,6], [1,0], [0.0002,0.00005], [[2,3,4],[6,3,4]], [15,7],
                                [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                                [0,0], [1,1], 1,
                                [1,1], [1,1])[1] == [4]

end

@testset "death_of_human" begin
    @test death_of_human([2,4], [0,6], [1,0], [0.0002,0.00005], [[2,3,4],[6,3,4]], [15,7],
                                [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                                [0,0], [1,1], 1,
                                [1,1], [1,1])[4] == [0.00005]

end


@testset "death_of_human" begin
    @test death_of_human([120,120], [0,0], [0.4,0.6], [[2,3,4],[6,3,4]], [15,7],
                                [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                                [0,0], [1,1], [0.00001,0.0001], 365,
                                [1,1], [1,1])[1] == []

end
age_death_rate_per_1000 = [6.56, 0.93, 0.3, 0.23, 0.27, 0.38, 0.44, 0.48,0.53, 0.65,
                           0.88, 1.06, 1.44, 2.1, 3.33, 5.29, 8.51, 13.66,
                           21.83, 29.98, 36.98]

contact_rates_by_age = make_age_contact_rate_array(100,"high adult", [], [])


#
# ages, death_ages, gender, predisposition, human_cercariae, eggs, vac_status,
#                         treated, female_worms, male_worms,vaccinated, age_contact_rate,
#                         female_factor, male_factor, contact_rates_by_age,
#                         worm_stages, predis_aggregation, predis_weight,
#                         adherence, death_prob_by_age, ages_for_deaths,
#                         mda_adherence, access, mda_access

death_prob_by_age = [0.0656, 0.0093, 0.003, 0.0023, 0.0027, 0.0038, 0.0044, 0.0048, 0.0053,
                          0.0065, 0.0088, 0.0106, 0.0144, 0.021, 0.0333, 0.0529, 0.0851, 0.1366, 0.2183, 0.2998 , 0.3698, 1]

ages_for_deaths = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60,
                        65, 70, 75, 80, 85, 90, 95, 100, 110]



    @testset "birth_of_human" begin
        @test birth_of_human([2,4], [0.44,0], [0,0], [1.1,1], [2,4],[[2,3,4],[6,3,4]], [15,7],
                                [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                                [0,0], [1.1,1], 1, 1, [0.0002,0.00005], 2,1, 1, [1,1],
                            death_prob_by_age, ages_for_deaths,[1,2,3,4], 0.8,[1,1], 0.9)[1] == [2,4,0]
    end
    new_pop = birth_of_human([2,4], [0.44,0], [0,0], [1.1,1],[2,4], [[2,3,4],[6,3,4]], [15,7],
                            [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                            [0,0], [1.1,1], 1, 1, [0.0002,0.00005], 2,1, 1, [1,1],
                        death_prob_by_age, ages_for_deaths,[1,2,3,4,5], 0.8,[1,1], 0.9)
    @testset "birth_of_human" begin
        @test new_pop[1]==[2,4,0]
    end
    @testset "birth_of_human" begin
        @test new_pop[6]==[[2,3,4],[6,3,4],[]]
    end

    @testset "birth_of_human" begin
        @test new_pop[7]==[15,7,0]
    end



@testset "administer_drug" begin
    @test administer_drug([[3,2],[3],[4,10]], [1,2], 1, [1,1,1]) == [[0,0],[0],[4,10]]
end




@testset "administer_drug" begin
    @test administer_drug([[3,2],[3],[4,10]], [1,2], 0, [1,1,1]) == [[3,2],[3],[4,10]]
end

Random.seed!(2525)
big_drug = administer_drug([[3, 2],[1e5],[4,10]], [2], 0.5, [1,1,1])
# I ran it with this seed so know the exact answer, so consider this a regression test.
@testset "administer_drug" begin
    @test big_drug == [[3,2],[50029],[4,10]]
end


@testset "create_mda" begin
     mda_info = create_mda(0, .75, 1, 1, 5, 2, [0,1], [0,1], [0,1], .92)
    @test mda_info[1].coverage == 0
end


out1 = out[]


@testset "create_output" begin
    push!(out1, out(1,2,3,4,5,6,7,8,9,10,11))
    @test out1[1].adult_burden == 3
end


@testset "create_output" begin
    push!(out1, out(1,2,35,4,5,6,7,8,9,10,11))
    @test out1[end].adult_burden == 35
end


@testset "create_mda" begin
     mda_info = create_mda(0, .75, 1, 1, 5, 1, [0,1], [0,1], [0,1], .92)
    @test mda_info[end].time == 5
end

mda_info = create_mda(0, .75, 1, 1, 5, 2, [0,1], [0,1], [0,1], .92)

@testset "update_mda" begin
    @test update_mda(mda_info, 3)[1] == 0
end

@testset "update_mda" begin
    @test update_mda(mda_info, 3)[5] == 3
end

@testset "update_mda" begin
    @test update_mda(mda_info, 30)[5] == Inf
end

  # But also with this big a sample size I think its fairly reasonable to use the 0.0001 and 0.9999 quantiles.
# In R qbinom(0.5, 1e5, c(0.0001, 0.9999))
# So this isn't relying on the seed, and should nearly always be true.
# but if we're repeatedly running it, we still want to use a seed.
@testset "administer_drug" begin
    @test (big_drug[2][1] > 10.0) & (big_drug[2][1] < 99990.0)
end


@testset "mda" begin
    @test isapprox(mda(1, 3, 8, 1,[0,1],
[2,5,4,7,9], [[1],[2],[3],[4],[5]], [[1],[2],[3],[4],[5]],
[[1],[2],[3],[4],[5]], [[1],[2],[3],[4],[5]],0,0,[1,1,1,1,1], [0,0,0,0,0],[0,0,0,0,0])[4],
[[1], [2], [3], [4], [5]])
end



@testset "mda" begin
    @test isapprox(mda(1, 3, 8, 1,[0,1],
[2,5,4,7,9], [[1],[2],[3],[4],[5]], [[1],[2],[3],[4],[5]],
[[1],[2],[3],[4],[5]], [[1],[2],[3],[4],[5]],0,0,[1,1,1,1,1], [1,1,1,1,1],[1,1,1,1,1])[1],
[[1], [0], [0], [0], [5]])
end

@testset "mda" begin
    @test isapprox(mda(1, 3, 8, 1,[0,1],
[2,5,4,7,9], [[1],[2],[3],[4],[5]], [[1],[2],[3],[4],[5]],
[[1],[2],[3],[4],[5]], [[1],[2],[3],[4],[5]],0,0,[1,1,1,1,1], [1,1,1,1,1],[1,1,1,1,1])[2],
[[1], [0], [0], [0], [5]])
end


#=
Run some tests on the population making function
Need to do some setup first though.
=#
 mda_access = 1
N = 1000
max_age = 100
initial_worms = 10
time_step = 10
worm_stages = 2
female_factor = 1
male_factor = 1
initial_miracidia = 1
initial_miracidia_days = trunc(Int,round(41/time_step, digits = 0))
env_cercariae = 0
#const contact_rate = 0.000005
age_death_rate_per_1000 = [6.56, 0.93, 0.3, 0.23, 0.27, 0.38, 0.44, 0.48,0.53, 0.65,
                           0.88, 1.06, 1.44, 2.1, 3.33, 5.29, 8.51, 13.66,
                           21.83, 29.98, 36.98]
predis_aggregation = 0.24
mda_adherence = 0.8
scenario = "high adult"
contact_rates_by_age = make_age_contact_rate_array(max_age, scenario, [], [])

predis_weight = 1

N_communities= 4
community_probs = [1,2,1,3]

@testset "create_pop" begin
@test_throws ErrorException("must provide probabilities for membership of each community") create_population(N, max_age, 100, community_probs, initial_worms, contact_rates_by_age,
worm_stages, female_factor, male_factor,
    initial_miracidia, initial_miracidia_days, predis_aggregation, predis_weight, time_step,
    mda_adherence, mda_access)
end

pop = create_population(N, max_age, N_communities, community_probs, initial_worms, contact_rates_by_age,
worm_stages, female_factor, male_factor,
    initial_miracidia, initial_miracidia_days, predis_aggregation, predis_weight, time_step,
    mda_adherence, mda_access)

pop = create_population(N, max_age, N_communities, community_probs, initial_worms, contact_rates_by_age,
worm_stages, female_factor, male_factor,
    initial_miracidia, initial_miracidia_days, predis_aggregation, predis_weight, time_step,
    mda_adherence, mda_access)

# These should all get give the initial value
@testset "miracidia" begin
    @test all(pop[13] .== initial_miracidia)
end

# Worms should be 0:ininity
# Get first column of worms
mworm1 = [pop[9][i][1] for i=1:length(pop[9])]
fworm1 = [pop[10][i][1] for i=1:length(pop[10])]
@testset "wormsm" begin
    @test all(mworm1 .>= 0)
end
@testset "wormsf" begin
    @test all(fworm1 .>= 0)
end

# All vectors except the last should be length N?
lens = [length(pop[i]) for i=1:(length(pop) - 3)]
push!(lens, length(pop[end]))
push!(lens, length(pop[end-1]))
@testset "N" begin
    @test all(lens .== N)
end





female_worms= [[1,1], [2,1], [2,4]]
male_worms= [[1,1], [2,1], [2,5]]
vaccine_effectiveness = 1
vaccine_coverage = 1
min_age_vaccine = 5
max_age_vaccine = 16
vaccine_gender = [0,1]
ages = [4,10,9]
death_ages = [5,11,66]
human_cercariae = [[1,2],[9,2,4], [ 0,5]]
eggs = [1,2,3]
treated = [1,1,1]
vaccine_duration = 10
vac_status = [0,0,0]
vaccine_round = 1
gender = [1,0,1]
adherence = [1,1,1]
access = [1,1,1]


@testset "vaccinate" begin
@test isapprox(vaccinate(vaccine_coverage, min_age_vaccine, max_age_vaccine, vaccine_effectiveness,
        vaccine_gender, ages, female_worms, male_worms, human_cercariae, eggs,
        treated, vaccine_duration, vac_status, vaccine_round, gender, access)[1],
        [[1,1],[0,0],[0,0]])
end

female_worms= [[1,1], [2,1], [2,4]]
male_worms= [[1,1], [2,1], [2,5]]
access = [1,1,1]



@testset "vaccinate" begin
@test isapprox(vaccinate(vaccine_coverage, min_age_vaccine, max_age_vaccine, vaccine_effectiveness,
            vaccine_gender, ages, female_worms, male_worms, human_cercariae, eggs,
            treated, vaccine_duration, vac_status, vaccine_round, gender,access)[1],
            [[1,1],[0,0],[0,0]])
end

female_worms= [[1,1], [2,1], [2,4]]
male_worms= [[1,1], [2,1], [2,5]]
access = [1,0,0]

@testset "vaccinate" begin
@test isapprox(vaccinate(vaccine_coverage, min_age_vaccine, max_age_vaccine, vaccine_effectiveness,
            vaccine_gender, ages, female_worms, male_worms, human_cercariae, eggs,
            treated, vaccine_duration, vac_status, vaccine_round, gender,access)[1],
            [[1,1],[2,1],[2,4]])
end

time_step = 10
num_time_steps = 1
community = 1,3,1
community_contact_rate = 1,0.5, 1
community_probs = 1,2,1
heavy_burden_threshold = 16
kato_katz_par = 0.87
use_kato_katz = 0
@testset "update_env" begin
    @test update_env(num_time_steps, [1,3,4], [2,5,8],community, community_contact_rate, community_probs, human_cercariae, female_worms, male_worms,
    time_step, 5.7,
    eggs, 0.34, 0.03, 2,
    vac_status, gender, 0.24,predis_weight,
    [0.2, 0.8,1], treated, vaccine_effectiveness,
    0.0005, death_prob_by_age, ages_for_deaths,
    [0,0,0], [0.02,0.04,0.03], env_miracidia,
    env_cercariae, 0.0005, 1, 1,
    1, 1, contact_rates_by_age,
    28*time_step/(1000*365), [], [], [1,1,1], 1,
    [1,1,1], 1,
    1/24,1, 24, heavy_burden_threshold,
    kato_katz_par, use_kato_katz)[1] ==  [1+(num_time_steps*time_step/365),3+(num_time_steps*time_step/365),4+(num_time_steps*time_step/365)]
end

mda_info = create_mda(0, .75, 1, 0, 5, 2, [0,1], [0,1], [0,1], .92)
push!(vaccine_info, vaccine_information(0.75, 4, 16, [0,1], 3, 0))
@testset "update_env" begin
    @test update_env(num_time_steps, [1,3,4], [2,5,8],community, community_contact_rate, community_probs, human_cercariae, female_worms, male_worms,
    time_step, 5.7,
    eggs, 0.34, 0.03, 2,
    vac_status, gender, 0.24,predis_weight,
    [0.2, 0.8,1], treated, vaccine_effectiveness,
    0.0005, death_prob_by_age, ages_for_deaths,
    [0,0,0], [0.02,0.04,0.03], env_miracidia,
    env_cercariae, 0.0005, 1, 1,
    1, 1, contact_rates_by_age,
    28*time_step/(1000*365), mda_info, vaccine_info, [1,1,1], 1,
    [1,1,1], 1,
    1/24,1, 24, heavy_burden_threshold,
    kato_katz_par, use_kato_katz)[1] ==  [1+(num_time_steps*time_step/365),3+(num_time_steps*time_step/365),4+(num_time_steps*time_step/365)]
end



spec_ages = 7639, 7082, 6524, 5674, 4725, 4147, 3928, 3362,
            2636, 1970, 1468, 1166, 943, 718, 455, 244
ages_per_index = 5

@testset "gen_age_dist" begin
    @test generate_age_distribution(spec_ages, ages_per_index)[end] == 1
end


@testset "gen_age_dist" begin
    @test generate_age_distribution(spec_ages, ages_per_index)[1] == spec_ages[1] / (sum(spec_ages)*5)
end

Random.seed!(25251)
@testset "gen_age_dist" begin
    @test specified_age_distribution(5, spec_ages, ages_per_index)[1] == 27
end


 mda_access = 1
N = 1000
max_age = 100
initial_worms = 10
time_step = 10
worm_stages = 2
female_factor = 1
male_factor = 1
initial_miracidia = 1
initial_miracidia_days = trunc(Int,round(41/time_step, digits = 0))
env_cercariae = 0
#const contact_rate = 0.000005
age_death_rate_per_1000 = [6.56, 0.93, 0.3, 0.23, 0.27, 0.38, 0.44, 0.48,0.53, 0.65,
                           0.88, 1.06, 1.44, 2.1, 3.33, 5.29, 8.51, 13.66,
                           21.83, 29.98, 36.98]
predis_aggregation = 0.24
mda_adherence = 0.8
scenario = "high adult"
contact_rates_by_age = make_age_contact_rate_array(max_age, scenario, [], [])

predis_weight = 1

N_communities= 4
community_probs = [1,2,1,3]


pop = create_population_specified_ages(N, N_communities, community_probs, initial_worms, contact_rates_by_age,
        worm_stages, female_factor, male_factor,initial_miracidia,
        initial_miracidia_days, predis_aggregation, predis_weight,
        time_step,
        spec_ages, ages_per_index, death_prob_by_age, ages_for_deaths,
        mda_adherence, mda_access)
        # These should all get give the initial value
@testset "miracidia" begin
    @test all(pop[14] .== initial_miracidia)
end

        # Worms should be 0:ininity
        # Get first column of worms
mworm1 = [pop[9][i][1] for i=1:length(pop[9])]
fworm1 = [pop[10][i][1] for i=1:length(pop[10])]
@testset "wormsm" begin
    @test all(mworm1 .>= 0)
end
@testset "wormsf" begin
    @test all(fworm1 .>= 0)
end

        # All vectors except the last should be length N?
lens = [length(pop[i]) for i=1:(length(pop) - 3)]
push!(lens, length(pop[end]))
push!(lens, length(pop[end-1]))
@testset "N" begin
    @test all(lens .== N)
end




@testset "death_of_human_s_p" begin
    @test death_of_human_save_predis([2,4], [0,6], [1,0], [0.0002,0.00005], [[2,3,4],[6,3,4]], [15,7],
                                [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                                [0,0], [1,1], 1,
                                [1,1], [1,1])[1] == [4]

end


a = death_of_human([2,4], [0,6], [1,0], [0.0002,0.00005], [[2,3,4],[6,3,4]], [15,7],
                                [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                                [0,0], [1,1], 1,
                                [1,1], [1,1])




b = death_of_human_save_predis([2,4], [0,6], [1,0], [0.0002,0.00005], [[2,3,4],[6,3,4]], [15,7],
                           [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                           [0,0], [1,1], 1,
                           [1,1], [1,1])

@testset "death_of_human_s_p" begin
    @test length(a) == length(b)-1
end




@testset "birth_of_human_s_p" begin
    @test birth_of_human_specified_predis([2,4], [0.44,0], [0,0], [1.1,1], [2,4],[[2,3,4],[6,3,4]], [15,7],
                                [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                                [0,0], [1.1,1], 1, 1, [0.0002,0.00005], 2,1, 1, [1,1],
                            death_prob_by_age, ages_for_deaths,[1,2,3,4], 0.8,[1,1], 0.9, 100)[1] == [2,4,0]
end
b1 = birth_of_human_specified_predis([2,4], [0.44,0], [0,0], [1.1,1], [2,4],[[2,3,4],[6,3,4]], [15,7],
                            [0,0], [0,0], [[9,2],[5,3]], [[0,3],[1,12]],
                            [0,0], [1.1,1], 1, 1, [0.0002,0.00005], 2,1, 1, [1,1],
                        death_prob_by_age, ages_for_deaths,[1,2,3,4], 0.8,[1,1], 0.9, 100)



@testset "birth_of_human_s_p" begin
    @test b1[4][end]== 100
end



gamma_k = Gamma(0.87,1/0.87)

@testset "kato_katz" begin
    @test  kato_katz(100, gamma_k) > 0
end


@testset "get_prev" begin
    @test isapprox(get_prevalences(pop[1], pop[7], 0, 16, 0.87, 0).population_burden, [0,0,0])
end

for i in 1:length(pop[7])
    pop[7][i] = 100
end


@testset "get_prev" begin
    @test isapprox(get_prevalences(pop[1], pop[7], 0, 16, 0.87, 0).population_burden, [100,100,100])
end

for i in 1:length(pop[7])
    pop[7][i] = 15
end






@testset "get_prev" begin
    @test isapprox(get_prevalences(pop[1], pop[7], 0, 16, 0.87, 0).population_burden, [100,100,0])
end



for i in 1:length(pop[7])
    pop[7][i] = 2
end


@testset "get_prev" begin
    @test isapprox(get_prevalences(pop[1], pop[7], 0, 16, 0.87, 0).population_burden, [100,0,0])
end


ages , death_ages, gender, predisposition, community,
   human_cercariae, eggs, vac_status,
   treated, female_worms, male_worms, age_contact_rate,
   vaccinated, env_miracidia, adherence, access = create_population_specified_ages(N, N_communities, community_probs, initial_worms, contact_rates_by_age,
                worm_stages, female_factor, male_factor,initial_miracidia,
                initial_miracidia_days, predis_aggregation, predis_weight,
                time_step,
                spec_ages, ages_per_index, death_prob_by_age, ages_for_deaths,
                mda_adherence, mda_access)

filename = "a.jld"


save_population_to_file(filename, ages, gender, predisposition, community, human_cercariae, eggs, vac_status, treated,
        female_worms, male_worms, vaccinated, age_contact_rate, death_ages, env_miracidia, env_cercariae, adherence, access)

@testset "load_data" begin
    aa  = load_population_from_file(filename, N, true)
    @test isapprox(aa[1],ages)
end


@testset "load_data" begin
    aa  = load_population_from_file(filename, 100, false)
    @test length(aa[1]) ==100
end


max_fecundity = 0.34

ages , death_ages, gender, predisposition, community,
   human_cercariae, eggs, vac_status,
   treated, female_worms, male_worms, age_contact_rate,
   vaccinated, env_miracidia, adherence, access = create_population_specified_ages(N, 1, 1, initial_worms, contact_rates_by_age,
                worm_stages, female_factor, male_factor,initial_miracidia,
                initial_miracidia_days, predis_aggregation, predis_weight,
                time_step,
                spec_ages, ages_per_index, death_prob_by_age, ages_for_deaths,
                mda_adherence, mda_access)

                    death_ages = []
                    for i in 1:N
                         push!(death_ages, get_death_age(death_prob_by_age, ages_for_deaths))
                    end
                    mean(death_ages)
                    ages, death_ages = generate_ages_and_deaths(2000, ages, death_ages, death_prob_by_age, ages_for_deaths, time_step)
age_contact_rate = update_contact_rate(ages, age_contact_rate, contact_rates_by_age)

mda_info = []
vaccine_info = []


@testset "update_env_same_pop" begin
ages_equ, death_ages_equ, gender_equ, predisposition_equ, community_equ, human_cercariae_equ, eggs_equ,
vac_status_equ, treated_equ, female_worms_equ, male_worms_equ,
vaccinated_equ, age_contact_rate_equ,
env_miracidia_equ, env_cercariae_equ, adherence_equ,access_equ,
record = update_env_keep_population_same(1, copy(ages), copy(death_ages), copy(community), 1,1,
    copy(human_cercariae), copy(female_worms), copy(male_worms),
    time_step, average_worm_lifespan,
    copy(eggs), max_fecundity, r, worm_stages,
    copy(vac_status), copy(gender), predis_aggregation,predis_weight,
    copy(predisposition), copy(treated), vaccine_effectiveness,
    density_dependent_fecundity, death_prob_by_age, ages_for_deaths,
    copy(vaccinated), copy(age_contact_rate), copy(env_miracidia),
    copy(env_cercariae), contact_rate, env_cercariae_survival_prop, env_miracidia_survival_prop,
    female_factor, male_factor, contact_rates_by_age,
    birth_rate, mda_info, vaccine_info, adherence, mda_adherence, access, mda_access,
    record_frequency, human_cercariae_prop, miracidia_maturity_time, heavy_burden_threshold,
    kato_katz_par, use_kato_katz)


@test env_miracidia_equ[end] > env_miracidia_equ[end-1]
end


@testset "update_env_same_pop_save_pre" begin
ages_equ, death_ages_equ, gender_equ, predisposition_equ, community_equ, human_cercariae_equ, eggs_equ,
vac_status_equ, treated_equ, female_worms_equ, male_worms_equ,
vaccinated_equ, age_contact_rate_equ,
env_miracidia_equ, env_cercariae_equ, adherence_equ,access_equ,
record = update_env_keep_population_same_save_predisposition(1, copy(ages), copy(death_ages), copy(community), 1,1,
    copy(human_cercariae), copy(female_worms), copy(male_worms),
    time_step, average_worm_lifespan,
    copy(eggs), max_fecundity, r, worm_stages,
    copy(vac_status), copy(gender), predis_aggregation,predis_weight,
    copy(predisposition), copy(treated), vaccine_effectiveness,
    density_dependent_fecundity, death_prob_by_age, ages_for_deaths,
    copy(vaccinated), copy(age_contact_rate), copy(env_miracidia),
    copy(env_cercariae), contact_rate, env_cercariae_survival_prop, env_miracidia_survival_prop,
    female_factor, male_factor, contact_rates_by_age,
    birth_rate, mda_info, vaccine_info, adherence, mda_adherence, access, mda_access,
    record_frequency, human_cercariae_prop, miracidia_maturity_time, heavy_burden_threshold,
    kato_katz_par, use_kato_katz)


@test env_miracidia_equ[end] > env_miracidia_equ[end-1]
end


@testset "update_env_to_equ" begin
    ages_equ, gender_equ, predisposition_equ,  human_cercariae_equ, eggs_equ,
    vac_status_equ, treated_equ, female_worms_equ, male_worms_equ,
    vaccinated_equ, env_miracidia_equ, env_cercariae_equ, record_high =
        update_env_to_equilibrium(1, copy(ages), copy(human_cercariae), copy(female_worms), copy(male_worms),
            copy(community),1,
            time_step, average_worm_lifespan,
            copy(eggs), max_fecundity, r, worm_stages,
            copy(vac_status), copy(gender), predis_aggregation,
            copy(predisposition), copy(treated), vaccine_effectiveness,
            density_dependent_fecundity, copy(vaccinated), copy(env_miracidia),
            copy(env_cercariae), contact_rate, env_cercariae_survival_prop, env_miracidia_survival_prop,
            female_factor, male_factor, contact_rates_by_age, record_frequency, copy(age_contact_rate),human_cercariae_prop,
            miracidia_maturity_time, heavy_burden_threshold, kato_katz_par, use_kato_katz)
    @test env_miracidia_equ[end] > env_miracidia_equ[end-1]
end

mda_info = create_mda(0, .75, 1, 1, 5, 2, [0,1], [0,1], [0,1], .92)
vaccine_info = []
push!(vaccine_info, vaccine_information(0.75, 4, 16, [0,1], 3, 0.4))
@testset "update_env_with_mda_no_births_deaths" begin
ages_equ, death_ages_equ, gender_equ, predisposition_equ, community_equ, human_cercariae_equ, eggs_equ,
vac_status_equ, treated_equ, female_worms_equ, male_worms_equ,
vaccinated_equ, age_contact_rate_equ,
env_miracidia_equ, env_cercariae_equ, adherence_equ,access_equ,
record = update_env_with_mda_no_births_deaths(1, copy(ages), copy(death_ages), copy(community), 1, 1,
    copy(human_cercariae), copy(female_worms), copy(male_worms),
    time_step, average_worm_lifespan,
    copy(eggs), max_fecundity, r, worm_stages,
    copy(vac_status), copy(gender), predis_aggregation,predis_weight,
    copy(predisposition), copy(treated), vaccine_effectiveness,
    density_dependent_fecundity, death_prob_by_age, ages_for_deaths,
    copy(vaccinated), copy(age_contact_rate), copy(env_miracidia),
    copy(env_cercariae), contact_rate, env_cercariae_survival_prop, env_miracidia_survival_prop,
    female_factor, male_factor, contact_rates_by_age,
    birth_rate, mda_info, vaccine_info, adherence, mda_adherence, access, mda_access,
    record_frequency, human_cercariae_prop, miracidia_maturity_time, heavy_burden_threshold,
    kato_katz_par, use_kato_katz)


@test env_miracidia_equ[end] > env_miracidia_equ[end-1]
end


@testset "update_env_with_mda_no_births_deaths" begin
ages_equ, death_ages_equ, gender_equ, predisposition_equ, community_equ, human_cercariae_equ, eggs_equ,
vac_status_equ, treated_equ, female_worms_equ, male_worms_equ,
vaccinated_equ, age_contact_rate_equ,
env_miracidia_equ, env_cercariae_equ, adherence_equ,access_equ,
record = update_env_with_mda_no_births_deaths(100, copy(ages), copy(death_ages), copy(community), 1, 1,
    copy(human_cercariae), copy(female_worms), copy(male_worms),
    time_step, average_worm_lifespan,
    copy(eggs), max_fecundity, r, worm_stages,
    copy(vac_status), copy(gender), predis_aggregation,predis_weight,
    copy(predisposition), copy(treated), vaccine_effectiveness,
    density_dependent_fecundity, death_prob_by_age, ages_for_deaths,
    copy(vaccinated), copy(age_contact_rate), copy(env_miracidia),
    copy(env_cercariae), contact_rate, env_cercariae_survival_prop, env_miracidia_survival_prop,
    female_factor, male_factor, contact_rates_by_age,
    birth_rate, mda_info, vaccine_info, adherence, mda_adherence, access, mda_access,
    record_frequency, human_cercariae_prop, miracidia_maturity_time, heavy_burden_threshold,
    kato_katz_par, use_kato_katz)


@test length(ages_equ) == length(ages)
end

times = []
prev = []
sac_prev = []
high_burden = []
high_burden_sac =[]
adult_prev = []
high_adult_burden = []



ages_equ, death_ages_equ, gender_equ, predisposition_equ, community_equ, human_cercariae_equ, eggs_equ,
vac_status_equ, treated_equ, female_worms_equ, male_worms_equ,
vaccinated_equ, age_contact_rate_equ,
env_miracidia_equ, env_cercariae_equ, adherence_equ,access_equ,
record = update_env_with_mda_no_births_deaths(100, copy(ages), copy(death_ages), copy(community), 1, 1,
    copy(human_cercariae), copy(female_worms), copy(male_worms),
    time_step, average_worm_lifespan,
    copy(eggs), max_fecundity, r, worm_stages,
    copy(vac_status), copy(gender), predis_aggregation,predis_weight,
    copy(predisposition), copy(treated), vaccine_effectiveness,
    density_dependent_fecundity, death_prob_by_age, ages_for_deaths,
    copy(vaccinated), copy(age_contact_rate), copy(env_miracidia),
    copy(env_cercariae), contact_rate, env_cercariae_survival_prop, env_miracidia_survival_prop,
    female_factor, male_factor, contact_rates_by_age,
    birth_rate, mda_info, vaccine_info, adherence, mda_adherence, access, mda_access,
    record_frequency, human_cercariae_prop, miracidia_maturity_time, heavy_burden_threshold,
    kato_katz_par, use_kato_katz)

@testset "collect_prevs" begin
    b = collect_prevs(times, prev, sac_prev, high_burden, high_burden_sac, adult_prev, high_adult_burden, record, 1)
    high_ad_burden = (p->p.adult_burden[3]).(record)
    x = randperm(length(high_ad_burden))[1]
    @test b[7][x][1] == high_ad_burden[x]
end



@testset "collect_prevs" begin
    b = collect_prevs(times, prev, sac_prev, high_burden, high_burden_sac, adult_prev, high_adult_burden, record, 2)
    high_ad_burden = (p->p.adult_burden[3]).(record)
    x = randperm(length(high_ad_burden))[1]
    @test ((b[7][x][2] == b[7][x][1]) & (b[7][x][2] == high_ad_burden[x]))
end
