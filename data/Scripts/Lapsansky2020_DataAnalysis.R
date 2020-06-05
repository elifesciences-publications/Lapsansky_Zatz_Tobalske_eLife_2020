# The following is the R script used for statistical analysis for the paper
# Lapsansky et al 2020 in eLife

# Load the required libraries (after installing them, if you need it)  ###################################################################
library(readxl)
library(car)
library(sjstats)

#Read in the important excel sheets - Note: The exact files paths are likely different on your system ####################################

Perp_Aq = read_excel(path = 'Perp/AquaticKinData_perp.xlsx', sheet = 'runAverages') 
Para = read_excel(path = 'Parallel/CombinedKinData_parallel.xlsx')
Fig5_all = read_excel(path = 'Perp/Figure5_SourceData.xlsx', sheet = 'allData')
Fig5_aquatic = read_excel(path = 'Perp/Figure5_SourceData.xlsx', sheet = 'aquaticData')
Fig6 = read_excel(path = 'Perp/Figure6_SourceData.xlsx', sheet = 'data')


#test for differences in Strouhal number between descending and level aquatic flight #####################################################

st <- aov(log(strouhal)~Species*type, data = Perp_Aq) # run model
outlierTest(st) # test for outliers
leveneTest(st) # test for homoscedasticity 
shapiro.test(st$residuals) # test for normality
anova(st) # output details of the model, with significance values
eta_sq(st) # report ETA-squared

# plot(st) # visualize model fit


with(Perp_Aq, interaction.plot(type,Species,strouhal)) # create an interaction plot

st.Tukey <- TukeyHSD(st) # perform Post hoc test using TukeyHSD
st.Tukey$`Species:type`[c(4,11,17,22),] # report relavant (i.e. within species) comparisons


st.mean <- tapply(Perp_Aq$strouhal, list(Perp_Aq$type, Perp_Aq$Species), mean) # output the mean of each species by condition
st.mean
tapply(Perp_Aq$strouhal, list(Perp_Aq$type, Perp_Aq$Species), sd) # output the sd of each species by condition


# test for stroke velocity  ##############################################################################################################


# Downstroke #############################################################################################################################


ds.mean <- tapply(Para$DownstrokeVelocity, list(Para$Species, Para$Fluid), mean)
ds.mean
tapply(Para$DownstrokeVelocity, list(Para$Species, Para$Fluid), sd)


with(Para, interaction.plot(Fluid,Species,DownstrokeVelocity)) # interaction plot

# Tests for downstroke velocities 
# Downstroke P-critical = 0.05/4 =0.0125

ds.CM <- t.test(DownstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Common murre")
ds.CM

ds.HP <- t.test(DownstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Horned puffin")
ds.HP

ds.PG <- t.test(DownstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Pigeon guillemot")
ds.PG

ds.TP <- t.test(DownstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Tufted puffin")
ds.TP

# output statistics of each test

ds.statistic <- c(ds.CM$statistic, ds.HP$statistic, ds.PG$statistic, ds.TP$statistic)
ds.df <- c(ds.CM$parameter, ds.HP$parameter, ds.PG$parameter, ds.TP$parameter)
ds.pvalue <- c(ds.CM$p.value, ds.HP$p.value, ds.PG$p.value, ds.TP$p.value)

ds.statistic 
ds.df
ds.pvalue


# Upstroke  ################################################################################################################################


us.mean <- tapply(Para$UpstrokeVelocity, list(Para$Species, Para$Fluid), mean)
us.mean
tapply(Para$UpstrokeVelocity, list(Para$Species, Para$Fluid), sd)


with(Para, interaction.plot(Fluid,Species,UpstrokeVelocity))

# Tests for downstroke velocities
# Upstroke P-critical = 0.05/4 =0.0125

us.CM <- t.test(UpstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Common murre")
us.CM

us.HP <- t.test(UpstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Horned puffin")
us.HP

us.PG <- t.test(UpstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Pigeon guillemot")
us.PG

us.TP <- t.test(UpstrokeVelocity~Fluid, var.equal = FALSE, data = Para, subset = Species == "Tufted puffin")
us.TP


# output statistics of each test

us.statistic <- c(us.CM$statistic, us.HP$statistic, us.PG$statistic, us.TP$statistic)
us.parameter <- c(us.CM$parameter, us.HP$parameter, us.PG$parameter, us.TP$parameter)
us.pvalue <- c(us.CM$p.value, us.HP$p.value, us.PG$p.value, us.TP$p.value)

us.statistic
us.parameter
us.pvalue


# Amplitude ##############################################################################################################

tapply(Para$Amplitude, list(Para$Fluid, Para$Species), mean)

Amplitude <- aov(log(Amplitude)~Species*Fluid, data = Para[c(-51),]) # run model
outlierTest(Amplitude)
leveneTest(Amplitude)
shapiro.test(Amplitude$residuals)
anova(Amplitude)
eta_sq(Amplitude)

#plot(Amplitude)

with(Para, interaction.plot(Fluid,Species,Amplitude))

Amplitude.Tukey <- TukeyHSD(Amplitude)
Amplitude.Tukey$`Species:Fluid`[c(4,11,17,22),]


##############################################################################

downDur.mean <- tapply(Para$downduration, list(Para$Species, Para$Fluid), mean)
downDur.mean
tapply(Para$downduration, list(Para$Species, Para$Fluid), sd)

with(Para, interaction.plot(Fluid,Species,downduration))

upDur.mean <- tapply(Para$upduration, list(Para$Species, Para$Fluid), mean)
upDur.mean
tapply(Para$upduration, list(Para$Species, Para$Fluid), sd)

with(Para, interaction.plot(Fluid,Species,upduration))


# Test for the relationship between stroke angle (i.e. stroke plane angle) and fluid medium (air vs water) #########################################

StrokeAngle.all <- aov(log(strokeAngle)~Species+fluid, data = Fig5_all[c(-5),]) #interaction not significant
outlierTest(StrokeAngle.all)
shapiro.test(StrokeAngle.all$residuals)
anova(StrokeAngle.all)
eta_sq(StrokeAngle.all)

#plot(StrokeAngle.all)

tapply(Fig5_all$strokeAngle, list(Fig5_all$Species, Fig5_all$fluid), mean)
tapply(Fig5_all$strokeAngle, list(Fig5_all$Species, Fig5_all$fluid), sd)

with(Fig5_all, interaction.plot(x.factor = fluid, Species, response = strokeAngle))

tapply(Fig5_all$strokeAngle, list(Fig5_all$type), mean)
tapply(Fig5_all$strokeAngle, list(Fig5_all$type), sd)

# Test for the relationship between stroke angle in water and angle of descent #####################################################################

StrokeAngle.aquatic <- lm(log(strokeAngle)~Species*descentAngle, data = Fig5_aquatic)
outlierTest(StrokeAngle.aquatic)
shapiro.test(StrokeAngle.aquatic$residuals)
anova(StrokeAngle.aquatic)
eta_sq(StrokeAngle.aquatic)

#plot(StrokeAngle.aquatic)

# Tests for relationship between chord angle and angle of descent ##################################################################################

upChordAngle <- lm(log(upstrokeChordAngle)~Species+descentAngle, data = Fig6) # interaction not significant
outlierTest(upChordAngle)
shapiro.test(upChordAngle$residuals)
anova(upChordAngle)
eta_sq(upChordAngle)

#plot(upChordAngle)

tapply(Fig6$upstrokeChordAngle, list(Fig6$Species, Fig6$type), mean)
tapply(Fig6$upstrokeChordAngle, list(Fig6$Species, Fig6$type), sd)


##############################################################################################

downChordAngle <- lm(log(downstrokeChordAngle)~Species*descentAngle, data = Fig6)
outlierTest(downChordAngle)
shapiro.test(downChordAngle$residuals)
anova(downChordAngle)
eta_sq(downChordAngle)

#plot(downChordAngle)

tapply(Fig6$downstrokeChordAngle, list(Fig6$Species, Fig6$type), mean)
tapply(Fig6$downstrokeChordAngle, list(Fig6$Species, Fig6$type), sd)

