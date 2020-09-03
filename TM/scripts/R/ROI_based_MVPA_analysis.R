# For plotting distance from the decision boundary in the TM task
# ROI based MVPA
# Created 200323 by JISU (ver. 1)
library(reshape2)
library(ggplot2)

freq <- read.csv("/Volumes/clmnlab/TM/behav_data/LowFreqOrder.dat", header = FALSE)
freq
freq.other <- freq[freq!=15]
freq.cent <- freq[freq==15]

subj.list <- c("04", "05", "06", "07", "08", "09", "10", "11")
b <- rep(NA, 3)

for (subj in subj.list){
  
  decs <- read.csv(paste0("/Volumes/clmnlab/TM/fMRI_data/MVPA/2020319_TM_SVC_Fan_allROI_decision_fn_TML",subj,"_PILOT.csv"))
  dim(decs)
  decs <- cbind(decs, freq.other)
  decs <- data.frame(decs)
  decs <- decs[,-1]
  names(decs) <- c(c(1:279), "freq")  ##ROI naming: bcuz there is no 260th roi in FAN, 
  # roi name-1 is the correct ROI name since 261
  
  accur <- read.csv(paste0("/Volumes/clmnlab/TM/fMRI_data/MVPA/2020319_TM_SVC_Fan_allROI_train_score.csv"))
  accur <- accur[accur$subject == paste0("TML",subj,"_PILOT"),]
  hist(accur$accu)      
  rois <- accur$roi[accur$accu > 0.6]
  
  a <- rep(NA, 10)
  for (roi in rois){
      a <- cbind(a, tapply(decs[,roi], decs$freq, mean))
    }
  
  a[,1] <- c(10:14, 16:20)
  colnames(a) <- c("Freq", rois)
  a <- melt(a, id.vars="Freq")
  visu.data <- a[-c(1:10),]
  names(visu.data) <- c("Freq", "Roi", "Decision")
  
  multiplot <- function(..., plotlist=NULL, file, cols=2, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  numPlots = length(plots)
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  if (numPlots==1) {
    print(plots[[1]])
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
  
  
  p <- ggplot(visu.data, aes(x=Freq, y=Decision, col=Roi)) +
    geom_line() +
    scale_x_continuous(breaks=c(10:14, 16:20)) +
    labs(title = paste0("Subject ",subj, "'s decision distance \nof ROIs with accuracy over 0.6" ), x="Frequency", y="Distance from the decision boundary")
  
  assign(paste0("p",subj), p)
  
  b <- rbind(b, visu.data)
  
}

pdf("/Volumes/clmnlab/TM/fMRI_data/MVPA/Decision distance of SVM.pdf", width = 20, height = 30)
multiplot(p04, p05, p06, p07, p08, p09, p10, p11, cols=2)
dev.off()

#
#b <- b[-1, ]
#c <- melt(tapply(b$Decision, b$Freq, mean))
#
#ggplot(c, aes(x=Var1, y=value)) +
#  geom_line() + 
#  scale_x_continuous(breaks=c(10:14, 16:20))
#
#
#
#d <- melt(tapply(accur$accu, accur$roi, mean))
#
#ggplot(d, aes(x=Var1, y=value)) +
#  geom_point() + 
#  scale_x_continuous(breaks=seq(1,280,10), aes(labels = "ROI")) +
#  scale_y_continuous(breaks=seq(0.45,0.6,0.025), aes(labels = "Accuracy"))
#


for (subj in subj.list){

  
decs_o <- read.csv(paste0("/Volumes/clmnlab/TM/fMRI_data/MVPA/2020319_TM_SVC_Fan_allROI_decision_fn_other_TML",subj,"_PILOT.csv"))
dim(decs_o)
decs_o <- cbind(decs_o, freq.other)
decs_o <- data.frame(decs_o)
decs_o <- decs_o[,-1]
names(decs_o) <- c(c(1:279), "freq")  ##ROI naming: bcuz there is no 260th roi in FAN, 
# roi name-1 is the correct ROI name since 261

decs_c <- read.csv(paste0("/Volumes/clmnlab/TM/fMRI_data/MVPA/2020319_TM_SVC_Fan_allROI_decision_fn_center_TML",subj,"_PILOT.csv"))
dim(decs_c)
decs_c <- cbind(decs_c, 15)
decs_c <- data.frame(decs_c)
decs_c <- decs_c[,-1]
names(decs_c) <- c(c(1:279), "freq")  ##ROI naming: bcuz there is no 260th roi in FAN, 
# roi name-1 is the correct ROI name since 261


decs_o$ans <- (decs_o$freq > decs_c$freq)
decs_c$ans <- (decs_o$freq > decs_c$freq)
decs_comp <- decs_o[,1:279] > decs_c[,1:279]
decs_comp <- data.frame(decs_comp)

decs_comp$freq <- decs_o$freq

melted_decs <- melt(decs_comp, id.vars = "freq")
judged.h.rat <- tapply(melted_decs$value, list(melted_decs$freq, melted_decs$variable), mean)
visu.data <- melt(judged.h.rat)
visu.data$Var2 = rep(c(1:279), each=10)

#p <- ggplot(visu.data, aes(x=Var1, y=value, group=Var2, col=Var2)) +
#  geom_line()
#
#pdf("/Volumes/clmnlab/TM/fMRI_data/MVPA/Neurometric Curve of all ROI.pdf", width = 100, height = 100)
#p
#dev.off()


visu.data2 <- visu.data[(visu.data$Var2 %in% rois),]

p <- ggplot(visu.data2, aes(x=Var1, y=value, group=Var2, col=Var2)) +
  geom_line() + 
  scale_x_continuous(breaks=c(10:14, 16:20)) +
  labs(title = paste0("Subject ",subj), x="Frequency", y="Prob. judged higher")

assign(paste0("p",subj), p)

}

pdf("/Volumes/clmnlab/TM/fMRI_data/MVPA/Neurometric Curve.pdf", width = 20, height = 30)
multiplot(p04, p05, p06, p07, p08, p09, p10, p11, cols=2)
dev.off()




roiname <- readxl::read_excel("/Volumes/clmnlab/GA/fmri_data/masks/Fan/fan280_fullname.xlsx", col_names = FALSE)
dim(roiname)
roiname <- as.data.frame(roiname)
roiname <- roiname[-260,1]

accur <- read.csv(paste0("/Volumes/clmnlab/TM/fMRI_data/MVPA/2020319_TM_SVC_Fan_allROI_train_score.csv"))
accur.mean <- data.frame(c(1:259, 260:279), tapply(accur$accu, accur$roi, mean))
colnames(accur.mean) <- c("ROI", "Accuracy")
accur.mean$rankings <- rank(-accur.mean$Accuracy) < 30
accur.mean$roiname <- roiname

ggplot(accur.mean, aes(x=ROI, y=Accuracy, col=rankings)) +
  geom_point() #+
  #geom_text(aes(label=roiname))

accur.rois <- accur.mean$ROI[rank(-accur.mean$Accuracy) < 30]
roiname[accur.rois]



#"Lt. precentral gyrus (BA4, tongue and larynx)"                          "Rt. precentral gyrus (BA6, caudal ventrolateral)"                      
#"Lt. superior temporal gyrus (BA41/42)"                                  "Lt. superior temporal gyrus (Te1.0 and Te1.2)"                         
#"Lt. superior temporal gyrus (BA22, caudal)"                             "Rt. superior temporal gyrus (BA22, caudal)"                            
#"Lt. superior temporal gyrus (BA22, rostral)"                            "Rt. middle temporal gyrus (BA21, rostral)"                             
#"Rt. middle temporal gyrus (aSTS, anterior superior temporal sulcus)"    "Rt. inferior temporal gyrus (BA20, intermediate ventral)"              
#"Rt. inferior temporal gyrus (BA20, rostral)"                            "Rt. fusiform gyrus (BA20, rostroventral)"                              
#"Lt. superior parietal lobule (BA7, postcentral)"                        "Rt. postcentral gyrus (BA1/2/3, upper limb, head, and face)"           
#"Rt. postcentral gyrus (BA1/2/3, trunk)"                                 "Lt. insular gyrus (vIa, ventral agranular)"                            
#"Lt. insular gyrus (dIa, dorsal agranular)"                              "Lt. insular gyrus (dId, dorsal dysgranular)"                           
#"Rt. insular gyrus (dId, dorsal dysgranular)"                            "Lt. cingulate gyrus (BA24, caudodorsal)"                               
#"Rt. medioventral occipital cortex (rLinG, rostral lingual gyrus)"       "Lt. lateral occipital cortex (msOccG, medial superior occipital gyrus)"
#"Lt. hippocampus (cHipp, caudal hippocampus)"                            "Rt. thalamus (mPMtha, premotor thalamus)"                              
#"Rt. thalamus (PPtha, posterior parietal thalamus)"                      "Lt. cerebellum (lobule V)"                                             
#"Lt. cerebellum (crus I)"                                                "Lt. substantia nigra"                                                  
