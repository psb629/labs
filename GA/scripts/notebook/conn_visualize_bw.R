library("reader")
library("reticulate")
library("cowplot")
# library("ggpubr")
library("devtools")
load_all("/Users/yerachoi/Documents/ggpubr_edStatCor")


pd <- import("pandas")
pickle_file <- "/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/MO_errts_AM1_recruitment_prac_late-early.pkl"
df_recruit <- pd$read_pickle(paste0(pickle_file))


# Entire dataframe
df_conn_comb <- data.frame(matrix(ncol=21, nrow=60))
names <- c("subj", "prac", "behav", 
           "rcr_dmn", "rcr_core", "rcr_dmsub", "rcr_core_dmsub",
           "rcr_vis",
           "rcr_mot",
           "intg_vis_dmn", "intg_vis_core", "intg_vis_dmsub", "intg_vis_core_dmsub",
           "intg_mot_dmn", "intg_mot_core", "intg_mot_dmsub", "intg_mot_core_dmsub",
           "intg_task_dmn", "intg_task_core", "intg_task_dmsub", "intg_task_core_dmsub"
           )
colnames(df_conn_comb) <- names

# subj
subj_vec <- c(
        "GA01", "GA02", "GA05", "GA07", "GA08", "GA11", "GA12", "GA13", "GA14", "GA15", "GA18", "GA19", "GA20", "GA21", "GA23", "GA26", "GA27", "GA28", "GA29", "GA30", "GA31", "GA32", "GA33", "GA34", "GA35", "GA36", "GA37", "GA38", "GA42", "GA44"
        )
# subj_vec <- c(
#         "GA01", "GA02", "GA05", "GA07", "GA08", "GA11", "GA12", "GA13", "GA14", "GA15", "GA18", "GA19", "GA20", "GA21", "GA23", "GA26", "GA27", "GA28", "GA29", "GA30", "GA31", "GA32", "GA33", "GA34", "GA35", "GA36", "GA37", "GA38", "GA42", "GA44",
#         "GB01", "GB02", "GB05", "GB07", "GB08", "GB11", "GB12", "GB13", "GB14", "GB15", "GB18", "GB19", "GB20", "GB21", "GB23", "GB26", "GB27", "GB28", "GB29", "GB30", "GB31", "GB32", "GB33", "GB34", "GB35", "GB36", "GB37", "GB38", "GB42", "GB44"
        # )
df_conn_comb$subj <- rep(subj_vec, each=2)
# prac
prac_vec <- rep(c('prac', 'unprac'), each=30)
df_conn_comb$prac <- prac_vec
# behav (rew)
behav_prac_file <- '/Volumes/clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/behaviors/rew_GB-GA_n30.1D'
behav_unprac_file <- '/Volumes/clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/behaviors/rew_gb-ga_unpracticed_n30.1D'
behav_prac <- as.double(readLines(paste(behav_prac_file, sep=" ")))
behav_unprac <- as.double(readLines(paste(behav_unprac_file, sep=" ")))
df_conn_comb$behav <- c(behav_prac, behav_unprac)

# Recruitment
# 1. DMN (core + dMsub + MTLsub)
rcr_dmn_prac <- as.double(df_recruit$`('prac', ('dmn', 'dmn'))`)
rcr_dmn_unprac <- as.double(df_recruit$`('unprac', ('dmn', 'dmn'))`)
df_conn_comb$rcr_dmn <- c(rcr_dmn_prac, rcr_dmn_unprac)
# 1-1. DMN core
rcr_core_prac <- as.double(df_recruit$`('prac', ('core', 'core'))`)
rcr_core_unprac <- as.double(df_recruit$`('unprac', ('core', 'core'))`)
df_conn_comb$rcr_core <- c(rcr_core_prac, rcr_core_unprac)
# 1-2. DMN dMsub
rcr_dmsub_prac <- as.double(df_recruit$`('prac', ('dmsub', 'dmsub'))`)
rcr_dmsub_unprac <- as.double(df_recruit$`('unprac', ('dmsub', 'dmsub'))`)
df_conn_comb$rcr_dmsub <- c(rcr_dmsub_prac, rcr_dmsub_unprac)
# 1-3. DMN core + dMsub
rcr_core_dmsub_prac <- as.double(df_recruit$`('prac', ('dmn_core_dmsub', 'dmn_core_dmsub'))`)
rcr_core_dmsub_unprac <- as.double(df_recruit$`('unprac', ('dmn_core_dmsub', 'dmn_core_dmsub'))`)
df_conn_comb$rcr_core_dmsub <- c(rcr_core_dmsub_prac, rcr_core_dmsub_unprac)
# 2. Visual (Yeo cluster 1)
rcr_vis_prac <- as.double(df_recruit$`('prac', ('visual', 'visual'))`)
rcr_vis_unprac <- as.double(df_recruit$`('unprac', ('visual', 'visual'))`)
df_conn_comb$rcr_vis <- c(rcr_vis_prac, rcr_vis_unprac)
# 3. Motor (7 n200 localizers)
rcr_mot_prac <- as.double(df_recruit$`('prac', ('motor', 'motor'))`)
rcr_mot_unprac <- as.double(df_recruit$`('unprac', ('motor', 'motor'))`)
df_conn_comb$rcr_mot <- c(rcr_mot_prac, rcr_mot_unprac)

# Integration
# 1. Visual-DMN
intg_vis_dmn_prac <- as.double(df_recruit$`('prac', ('visual', 'dmn'))`)
intg_vis_dmn_unprac <- as.double(df_recruit$`('unprac', ('visual', 'dmn'))`)
df_conn_comb$intg_vis_dmn <- c(intg_vis_dmn_prac, intg_vis_dmn_unprac)
# 1-1. Visual-DMN core
intg_vis_core_prac <- as.double(df_recruit$`('prac', ('visual', 'core'))`)
intg_vis_core_unprac <- as.double(df_recruit$`('unprac', ('visual', 'core'))`)
df_conn_comb$intg_vis_core <- c(intg_vis_core_prac, intg_vis_core_unprac)
# 1-2. Visual-DMN dMsub
intg_vis_dmsub_prac <- as.double(df_recruit$`('prac', ('visual', 'dmsub'))`)
intg_vis_dmsub_unprac <- as.double(df_recruit$`('unprac', ('visual', 'dmsub'))`)
df_conn_comb$intg_vis_dmsub <- c(intg_vis_dmsub_prac, intg_vis_dmsub_unprac)
# 1-3. Visual-DMN core + dMsub
intg_vis_core_dmsub_prac <- as.double(df_recruit$`('prac', ('visual', 'dmn_core_dmsub'))`)
intg_vis_core_dmsub_unprac <- as.double(df_recruit$`('unprac', ('visual', 'dmn_core_dmsub'))`)
df_conn_comb$intg_vis_core_dmsub <- c(intg_vis_core_dmsub_prac, intg_vis_core_dmsub_unprac)

# 2. Motor-DMN
intg_mot_dmn_prac <- as.double(df_recruit$`('prac', ('motor', 'dmn'))`)
intg_mot_dmn_unprac <- as.double(df_recruit$`('unprac', ('motor', 'dmn'))`)
df_conn_comb$intg_mot_dmn <- c(intg_mot_dmn_prac, intg_mot_dmn_unprac)
# 2-1. Motor-DMN core
intg_mot_core_prac <- as.double(df_recruit$`('prac', ('motor', 'core'))`)
intg_mot_core_unprac <- as.double(df_recruit$`('unprac', ('motor', 'core'))`)
df_conn_comb$intg_mot_core <- c(intg_mot_core_prac, intg_mot_core_unprac)
# 2-2. Motor-DMN dMsub
intg_mot_dmsub_prac <- as.double(df_recruit$`('prac', ('motor', 'dmsub'))`)
intg_mot_dmsub_unprac <- as.double(df_recruit$`('unprac', ('motor', 'dmsub'))`)
df_conn_comb$intg_mot_dmsub <- c(intg_mot_dmsub_prac, intg_mot_dmsub_unprac)
# 2-2. Motor-DMN core + dMsub
intg_mot_core_dmsub_prac <- as.double(df_recruit$`('prac', ('motor', 'dmn_core_dmsub'))`)
intg_mot_core_dmsub_unprac <- as.double(df_recruit$`('unprac', ('motor', 'dmn_core_dmsub'))`)
df_conn_comb$intg_mot_core_dmsub <- c(intg_mot_core_dmsub_prac, intg_mot_core_dmsub_unprac)

# 3. Task-DMN
intg_task_dmn_prac <- as.double(df_recruit$`('prac', ('task', 'dmn'))`)
intg_task_dmn_unprac <- as.double(df_recruit$`('unprac', ('task', 'dmn'))`)
df_conn_comb$intg_task_dmn <- c(intg_task_dmn_prac, intg_task_dmn_unprac)
# 3-1. Task-DMN core
intg_task_core_prac <- as.double(df_recruit$`('prac', ('task', 'core'))`)
intg_task_core_unprac <- as.double(df_recruit$`('unprac', ('task', 'core'))`)
df_conn_comb$intg_task_core <- c(intg_task_core_prac, intg_task_core_unprac)
# 3-2. Task-DMN dMsub
intg_task_dmsub_prac <- as.double(df_recruit$`('prac', ('task', 'dmsub'))`)
intg_task_dmsub_unprac <- as.double(df_recruit$`('unprac', ('task', 'dmsub'))`)
df_conn_comb$intg_task_dmsub <- c(intg_task_dmsub_prac, intg_task_dmsub_unprac)
# 3-3. Task-DMN core + dMsub
intg_task_core_dmsub_prac <- as.double(df_recruit$`('prac', ('task', 'dmn_core_dmsub'))`)
intg_task_core_dmsub_unprac <- as.double(df_recruit$`('unprac', ('task', 'dmn_core_dmsub'))`)
df_conn_comb$intg_task_core_dmsub <- c(intg_task_core_dmsub_prac, intg_task_core_dmsub_unprac)


conn_names <- names(df_conn_comb)[4:length(names(df_conn_comb))]
conn_labels <- c("DMN recruitment", "Core recruitment", "dMsub recruitment", "Core/dMsub recruitment",
                 "Visual recruitment",
                 "Motor recruitment",
                 "Visual-DMN integration", "Visual-Core integration", "Visual-dMsub integration", "Visual-Core/dMsub integration",
                 "Motor-DMN integration", "Motor-Core integration", "Motor-dMsub integration", "Motor-Core/dMsub integration",
                 "Task-DMN integration", "Task-Core integration", "Task-dMsub integration", "Task-Core/dMsub integration"
                 )
df_conn_show <- data.frame(conn_names, conn_labels)
df_conn_show[ , 'plot'] <- NA


# ggscatter_conn <- function(conn_name, conn_label) {
#         plot <- ggscatter(df_conn_comb, x = conn_name, y = "behav", color = "prac",
#                           add = "reg.line",
#                           xlab = conn_label,
#                           ylab = "Late-early reward rate",
#                           palette = c("#00A8AA", "#C5C7D2"),
#                           conf.int = TRUE, conf.int.level = 0.95,
#                           fullrange = TRUE
#                         ) +
#                         stat_cor(aes(color = prac),
#                         method = "pearson")
#         return(plot)
# }

ggscatter_conn <- function(conn_name, conn_label) {
        # select prac data only
        data <- subset(df_conn_comb, prac == "prac")
        # ttest_res <- t.test(data$conn_name, mu = 0, alternative = "two.sided")
        # ttest_txt <- paste0("italic(t)~`=`~", abs(ttest_res$statistic), "*`,`~",
        #                     "italic(p)~`=`~", ttest_res$p.value)
        plot <- ggscatter(data, x = conn_name, y = "behav",
                          add = "reg.line",
                          add.params = list(color = "black", fill = "darkgray"),
                          xlab = conn_label,
                          ylab = "Improvement in success rate",
                          # color = "#00A8AA",
                          conf.int = TRUE, conf.int.level = 0.95,
                          # cor.coef = TRUE, cor.coeff.args = list(method = "pearson", label.sep = "\n"),
                          # cor.coef = TRUE,
                          # cor.coeff.args = list(method = "pearson", size = 4),
                          fullrange = TRUE
                        ) 
                        # +
                        # stat_cor(method = "pearson") +
                        # annotate(geom="text", x=0, y=0, label=ttest_txt)
        plot <-
        plot +
        geom_point(shape = 18, colour = "#F23A29", size = 4)
        theme_pubr() +
        theme(axis.title.x = element_text(margin = margin(t = 5, r = 0, b = 0, l = 0)),
              axis.title.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0)))

        return(plot)
}

p1 <- ggscatter_conn('intg_vis_core', 'Visual-DMN Core Integration')
p1

p1_ed <-
p1 +
stat_cor(method = "pearson", size = 4, label.x = 0.1, label.y = 0.6) +
scale_x_continuous(expand=c(0,0), limits=c(-0.52,0.52), breaks=seq(-0.4,0.4,0.2)) +
scale_y_continuous(expand=c(0,0), limits=c(-0.01,0.8)) +
coord_cartesian(xlim=c(-0.5,0.5), ylim=c(-0.01,0.8))


p1_ed
ggsave("/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/intg_vis_core.png",
       plot = p1_ed,
       device = "png",
       dpi = "retina"
       )

# p2 <- ggscatter_conn('intg_mot_core', 'Motor-DMN Core Integration')
# p2

# p2_ed <-
# p2 +
# stat_cor(method = "pearson", label.x = 0.2, label.y = 0.6) +
# scale_x_continuous(expand=c(0,0), limits=c(-0.62,0.62)) +
# scale_y_continuous(expand=c(0,0), limits=c(0,0.8)) +
# coord_cartesian(xlim=c(-0.52,0.52), ylim=c(0.0,0.8))

# p2_ed
# ggsave("/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/rcr_core.png",
#        plot = p2_ed,
#        device = "png",
#        dpi = "retina"
#        )

p3 <- ggscatter_conn('rcr_core', 'DMN Core Recruitment')
p3

p3_ed <-
p3 +
stat_cor(method = "pearson", label.x = 0.05, label.y = 0.6) +
scale_x_continuous(expand=c(0,0), limits=c(-0.22,0.22)) +
scale_y_continuous(expand=c(0,0), limits=c(-0.01,0.8)) + 
coord_cartesian(xlim=c(-0.22,0.22), ylim=c(-0.01,0.8))

p3_ed
ggsave("/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/rcr_core.png",
       plot = p3_ed,
       device = "png",
       dpi = "retina"
       )


p4 <- ggscatter_conn('rcr_vis', 'Visual Recruitment')
p4

p4_ed <-
p4 +
stat_cor(method = "pearson", label.x = 0.05, label.y = 0.65) +
scale_x_continuous(expand=c(0,0), limits=c(-0.32,0.32)) +
scale_y_continuous(expand=c(0,0), limits=c(-0.01,0.8)) + 
coord_cartesian(xlim=c(-0.28,0.28), ylim=c(-0.01,0.8))

p4_ed
ggsave("/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/rcr_vis.png",
       plot = p4_ed,
       device = "png",
       dpi = "retina"
       )

p5 <- ggscatter_conn('rcr_mot', 'Motor Recruitment')
p5

p5_ed <-
p5 +
stat_cor(method = "pearson", label.x = 0.05, label.y = 0.6) +
scale_x_continuous(expand=c(0,0), limits=c(-0.22,0.22)) +
scale_y_continuous(expand=c(0,0), limits=c(0,0.8))

p5_ed


p6 <- ggscatter_conn('intg_task_core', 'Task-DMN Core Integration')
p6

p6_ed <-
p6 +
stat_cor(method = "pearson", label.x = 0.1, label.y = 0.6) +
scale_x_continuous(expand=c(0,0), limits=c(-0.58,0.58)) +
scale_y_continuous(expand=c(0,0), limits=c(0,0.8))

p6_ed


p7 <- ggscatter_conn('rcr_dmn', 'DMN Recruitment')
p7

p7_ed <-
p7 +
stat_cor(method = "pearson", label.x = 0.05, label.y = 0.65) +
scale_x_continuous(expand=c(0,0), limits=c(-0.27,0.27)) +
scale_y_continuous(expand=c(0,0), limits=c(-0.01,0.8)) + 
coord_cartesian(xlim=c(-0.27,0.27), ylim=c(-0.01,0.8))

p7_ed
ggsave("/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/rcr_dmn.png",
       plot = p7_ed,
       device = "png",
       dpi = "retina"
       )


p7 <- ggscatter_conn('rcr_dmn', 'DMN Recruitment')
p7


p8 <- ggscatter_conn('rcr_dmsub', 'DMN dMsub Recruitment')
p8

p8_ed <-
p8 +
stat_cor(method = "pearson", label.x = 0.05, label.y = 0.65) +
scale_x_continuous(expand=c(0,0), limits=c(-0.27,0.27)) +
scale_y_continuous(expand=c(0,0), limits=c(-0.01,0.8)) + 
coord_cartesian(xlim=c(-0.27,0.27), ylim=c(-0.01,0.8))

p8_ed
ggsave("/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/rcr_dmn_dmsub.png",
       plot = p8_ed,
       device = "png",
       dpi = "retina"
       )


p8 <- ggscatter_conn('rcr_dmsub', 'DMN dMsub Recruitment')
p8

p8_ed <-
p8 +
stat_cor(method = "pearson", label.x = 0.05, label.y = 0.65) +
scale_x_continuous(expand=c(0,0), limits=c(-0.27,0.27)) +
scale_y_continuous(expand=c(0,0), limits=c(-0.01,0.8)) + 
coord_cartesian(xlim=c(-0.27,0.27), ylim=c(-0.01,0.8))

p8_ed
ggsave("/Volumes/clmnlab/GA/fmri_data/glm_results/MO_errts/rcr_dmn_dmsub.png",
       plot = p8_ed,
       device = "png",
       dpi = "retina"
       )

# coord_cartesian(xlim=c(-0.3,0.2), ylim=c(-0.25,0.75)) +

# plotList <- vector('list', nrow(df_conn_show))
# for (row in 1:nrow(df_conn_show)) {
#         conn_name = df_conn_show[row, "conn_names"]
#         conn_label = df_conn_show[row, "conn_labels"]

#         ggscatter_conn(conn_name, conn_label)
#         df_conn_show[row, "plot"] <- recordPlot()
# }


# p3 <- ggscatter(df_comb_recruit, x = "recruit_dmn", y = "behav", color = "prac",
#                 # combine = TRUE,
#                 add = "reg.line", 
#                 xlab = "Recruitment",
#                 ylab = "Late-early reward rate",
#                 # xlim = c(-0.3,0.2), 
#                 # ylim = c(-0.25,0.75),
#                 palette = c("#00A8AA", "#C5C7D2"),
#                 conf.int = TRUE, conf.int.level = 0.95,
#                 fullrange = TRUE
#                 ) +
#                 # scale_x_continuous(expand=c(0,0), limits=c(-0.35,0.25)) +
#                 # scale_y_continuous(expand=c(0,0), limits=c(-0.30,0.80)) +
#                 # coord_cartesian(xlim=c(-0.3,0.2), ylim=c(-0.25,0.75)) +
#                 stat_cor(aes(color = prac),
#                          method = "pearson", 
#                         #  label.x = 0.05, label.y = c(0.65, 0.60)
#                          )
# p3 <-
# p3 +
# # geom_point(size = 2.5) + 
# theme_pubr()

# p3