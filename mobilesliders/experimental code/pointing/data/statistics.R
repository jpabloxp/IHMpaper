
#///////////////////////////////////////////////////
#NORMALITY
#///////////////////////////////////////////////////

mvtimenorm <-  read.csv(file="/Users/juanrosso/Documents/Doctorado/graspme/analisis_participantes_xp1.csv",head=TRUE,sep=";")
mvtimenorm

shapiro.test(mvtimenorm$MovementTime)
shapiro.test(mvtimenorm$Overshoot)

#///////////////////////////////////////////////////
#Homogeneity
#///////////////////////////////////////////////////

bartlett.test(MovementTime~Length, mvtimenorm)
bartlett.test(MovementTime~Orientation, mvtimenorm)
bartlett.test(MovementTime~Grasp, mvtimenorm)

bartlett.test(Overshoot~Length, mvtimenorm)
bartlett.test(Overshoot~Orientation, mvtimenorm)
bartlett.test(Overshoot~Grasp, mvtimenorm)

#///////////////////////////////////////////////////
#ANOVA
#///////////////////////////////////////////////////

a1 <- aov(MovementTime~(Length*Orientation*Grasp) + Error(Participant/(Length*Orientation*Grasp)), data=mvtimenorm)
summary(a1)
a2 <- aov(Overshoot~(Length*Orientation*Grasp) + Error(Participant/(Length*Orientation*Grasp)), data=mvtimenorm)
summary(a2)

#///////////////////////////////////////////////////
#POST HOC
#///////////////////////////////////////////////////

posthoc <- TukeyHSD(a1, mvtimenorm$Grasp, conf.level=0.95)
summary(posthoc)

#///////////////////////////////////////////////////
#PLOT MOVEMENT TIME
#///////////////////////////////////////////////////

mvtimenorm <-  read.csv(file="/Users/juanrosso/Documents/Doctorado/graspme/analisis_participantes_xp1.csv",head=TRUE,sep=";")

library("sciplot", lib.loc="/Users/juanrosso/Documents/R Workspace/")
algo <- mvtimenorm$MovementTime
lineplot.CI(x.factor = mvtimenorm$Mixed, algo, group=mvtimenorm$Grasp, type="p", err.width=0, 
            ci.fun= function(algo) {
              nb = length(algo)
              icp = mean(algo, na.rm=TRUE) + 1.96 * sd(algo) / sqrt(nb)
              icm = mean(algo, na.rm=TRUE) - 1.96 * sd(algo) / sqrt(nb)
              return(c(icm, icp))
            }, xlab="Conditions", ylab="Mean Movement Time (s)", pch = c(18,16,15), ylim=range(0,2.5))
grid (NA, NULL, lty = 6, col = "cornsilk2")

#///////////////////////////////////////////////////
#PLOT OVERSHOOT
#///////////////////////////////////////////////////
  
mvtimenorm <-  read.csv(file="/Users/juanrosso/Documents/Doctorado/graspme/analisis_participantes_xp1.csv",head=TRUE,sep=";")

library("sciplot", lib.loc="/Users/juanrosso/Documents/R Workspace/")
algo <- mvtimenorm$Overshoot
lineplot.CI(x.factor = mvtimenorm$Mixed, algo, group=mvtimenorm$Grasp, type="p", err.width=0, 
            ci.fun= function(algo) {
              nb = length(algo)
              icp = mean(algo, na.rm=TRUE) + 1.96 * sd(algo) / sqrt(nb)
              icm = mean(algo, na.rm=TRUE) - 1.96 * sd(algo) / sqrt(nb)
              return(c(icm, icp))
            }, xlab="Conditions", ylab="Overshoot", pch = c(18,16,15), ylim=range(0,15))
grid (NA, NULL, lty = 6, col = "cornsilk2")


#///////////////////////////////////////////////////
#FRIEDMAN TEST AND PAIRWISE
#///////////////////////////////////////////////////

mvtimenorm <-  read.csv(file="/Users/juanrosso/Documents/Doctorado/graspme/forNormality.csv",head=TRUE,sep=";")
mvtimenorm
data2 <- cbind(mvtimenorm[mvtimenorm$Length.Orientation=='small-vertical',]$Overshoot, mvtimenorm[mvtimenorm$Length.Orientation=='small-tilted',]$Overshoot, mvtimenorm[mvtimenorm$Length.Orientation=='large-vertical',]$Overshoot, mvtimenorm[mvtimenorm$Length.Orientation=='large-tilted',]$Overshoot)
data2
friedman.test(data2)

pairwise.wilcox.test(mvtimenorm$MovementTime, mvtimenorm$Length.Orientation, p.adj="bonferroni", exact=F, paired=T)
pairwise.wilcox.test(mvtimenorm$Overshoot, mvtimenorm$Length.Orientation, p.adj="bonferroni", exact=F, paired=T)

aggregate(mvtimenorm[, 3:4], list(mvtimenorm$Length.Orientation), mean)
aggregate(mvtimenorm[, 3:4], list(mvtimenorm$Grasp), mean)
