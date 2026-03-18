library(genepop)

M1_genepop_run <- ibd(
  inputFile = "M1_genepop3.txt",
  outputFile = "M1_genepop3_out.txt",
  statistic = "a",
  dataType = "Diploid",
  settingsFile = "",
  geographicScale = "2D",
  verbose = interactive()
)
